#!/bin/bash

config_variables=(
	SYSTEMD_DIR
	SYSTEMD_OLD_DIR
	KERNEL_VERSION
	LOADER_ENTRY
	BACKUP_DIR
)


config_help_command() {
  cat <<-EOF
	Usage: $BIN_NAME config <subcommand>

	Subcommands:
	    validate    Validate the configuration file
	    edit        Edit the configuration file
	    help        Show this help message
	EOF
}

config_command() {
  local config_subcommand="config_${1:-help}"
  [[ $# -gt 0 ]] && shift
  run_cmd "$config_subcommand" "$@"
}

config_validate_command()
{ config_load_command "$@"
}
config_load_command() {
	local config_file="${1:-$config_file}"
	if [ ! -f "$config_file" ]; then
		exit_error "config file $config_file does not exist"
	fi

	# Unset all config variables before reloading the config
	unset -v ${config_variables[*]}

  # shellcheck source=/dev/null
  source "$config_file" &>/dev/null || exit_error "failed loading config $config_file"

  set +u
  for var in ${config_variables[@]}; do
    if [ -z "${!var}" ]; then
      exit_error "$var is not set in $config_file"
    fi
  done
  set -u
}

config_edit_command() {
	# Create a temporary copy of the config file to edit
  tmp_config_file="$(mktemp --tmpdir boot-manager.config.XXXXXX)"
	trap 'rm -rf "$tmp_config_file"' EXIT
	cp "$config_file" "$tmp_config_file"

	# Open the temporary config file in the editor
  ${EDITOR:-vi} "$tmp_config_file"

	# Validate the edited config file
	config_load_command "$tmp_config_file"

	# If validation passed, replace the original config file with the edited one
	cp "$tmp_config_file" "$config_file"
}
