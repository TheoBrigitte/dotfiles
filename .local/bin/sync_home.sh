#!/usr/bin/env bash

set -eu

SOURCE_DIR="${HOME%/}/"
CONFIG_DIR="$HOME/.config/sync_home"
LOG_DIR="$HOME/.config/sync_home/logs"
DRY_RUN=false

# Helper function - prints a message to stderr
echo_stderr() {
    >&2 echo "$@"
}

# Helper function - prints an error message and exits
exit_error() {
    echo_stderr "Error: $1"
    exit 1
}

# Helper function - shows the usage message and exits
usage() {
    script_name="$(basename "$0")"
    cat <<-EOF
		Usage: ${script_name} target -- [rsync options]
		  This is a wrapper around rsync to help backup home directory.

		  It does sync $SOURCE_DIR to the given target
		  It excludes files listed in $CONFIG_DIR/excludes
		  It logs the output to $LOG_DIR/YYYYMMDD_HHMMSS.log

		Arguments:
		  target: the destination directory to sync to
		          can be a local path or a remote path in the form of user@host:path
		  --: separates the target from the rsync options
		  rsync options: additional options to pass to rsync

		Options:
		  -h: show this help message

		Example:
		  ${script_name} /media/backup/
		  ${script_name} remote_host:/media/backup/
		  ${script_name} /media/backup/ -- --dry-run

		Note:
		  The source directory is hardcoded to $SOURCE_DIR
EOF
}

### Main function ###
main() {
    local target=""

    # Manage the command line arguments
    args=()
    while [[ $# -gt 0 ]]; do
      case $1 in
        --)
          # End of options, remaining arguments are rsync options.
          shift
          args+=("$@")
          break;;
        -h|--help)
          usage
          exit 0;;
        -n|--dry-run)
          DRY_RUN=true;;
        -?*)
          echo_stderr "Unknown option: $1"
          usage
          exit 1;;
        *)
          args+=("$1");;
      esac
      shift
    done

    set -- "${args[@]}" # Reset positional parameters to remaining arguments.

    targets=""
    if [[ -n "${1:-}" ]]; then
        targets="$1"
        if [[ -z "$targets" ]]; then
          echo_stderr "Please provide at least one target."
          echo_stderr ""
          usage
          exit 1
        fi
        shift

        exec 3< <(echo "$targets" | tr ',' '\n')
    else
      if [[ ! -s ~/.config/sync_home/targets ]]; then
          echo_stderr "No targets found in ~/.config/sync_home/targets."
          echo_stderr "Please provide a target or create the targets file."
          exit 1
      fi

      exec 3< ~/.config/sync_home/targets
    fi

    while IFS= read -r -u3 target; do
        if [[ -z "$target" || "$target" =~ ^\s*# ]]; then
            continue
        fi

        # Ensure the target ends with a slash
        target="${target%/}/"

        echo "> Syncing to target: $target"
        sync_target "$target" "${args[@]}"
    done
}

sync_target() {
    local target="$1"; shift
    local additional_args="${@}"

    log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S).log"
    if [[ "$additional_args" =~ --dry-run|-n ]]; then
        log_file="$log_file.dry-run"
    fi
    log_arg="--log-file=$log_file"

    echo "> source:        $SOURCE_DIR"
    echo "> target:        $target"
    echo "> logging to:    $log_file"
    echo "> rsync options: $additional_args"

    $DRY_RUN && \
      echo "> DRY RUN mode enabled. Stopping here." && \
      exit 0

    mkdir -p "$CONFIG_DIR" "$LOG_DIR"

    rsync -avP \
      --delete \
      --delete-excluded \
      --stats \
      --human-readable \
      --exclude-from ~/.config/sync_home/excludes \
      $log_arg \
      $additional_args \
      "$SOURCE_DIR" "$target"

    echo "> logged to: $log_file"
    echo "> done"
}

main "$@"
