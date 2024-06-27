#!/usr/bin/env bash

set -eu

SOURCE_DIR="${HOME%/}/"
CONFIG_DIR="$HOME/.config/sync_home"
LOG_DIR="$HOME/.config/sync_home/logs"

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
    echo_stderr "Usage: ${script_name} target"
    echo_stderr "  This is a wrapper around rsync to help backup home directory."
    echo_stderr ""
    echo_stderr "  It does sync $SOURCE_DIR to the given target"
    echo_stderr "  It excludes files listed in $CONFIG_DIR/excludes"
    echo_stderr "  It logs the output to $LOG_DIR/YYYYMMDD_HHMMSS.log"
}

### Main function ###
main() {
    local target=""

    # Manage the command line arguments
    ARGS=$(getopt -o 'h' --long 'help' -- "$@")
    eval set -- "$ARGS"
    unset ARGS

    while true; do
      case "$1" in
        '-h'|'--help')
          usage
          exit 0
          ;;
        '--')
          shift
          break
          ;;
        *)
          exit_error 'Internal error!'
          ;;
      esac
    done
    target=${@:$OPTIND:1}
    shift

    if [[ "$target" == "" ]]; then
        echo_stderr "Please provide a target."
        echo_stderr ""
        usage
        exit 1
    fi
    target="${target%/}/"
    log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S).log"

    echo "> source:     $SOURCE_DIR"
    echo "> target:     $target"
    echo "> logging to: $log_file"

    mkdir -p "$CONFIG_DIR" "$LOG_DIR"

    rsync -avP \
      --exclude-from ~/.config/sync_home/excludes \
      --log-file="$log_file" \
      "$SOURCE_DIR" "$target"

    echo "> logged to: $log_file"
}

main "$@"
