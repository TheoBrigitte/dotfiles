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
    echo_stderr "Usage: ${script_name} target -- [rsync options]"
    echo_stderr "  This is a wrapper around rsync to help backup home directory."
    echo_stderr ""
    echo_stderr "  It does sync $SOURCE_DIR to the given target"
    echo_stderr "  It excludes files listed in $CONFIG_DIR/excludes"
    echo_stderr "  It logs the output to $LOG_DIR/YYYYMMDD_HHMMSS.log"
    echo_stderr ""
    echo_stderr "Arguments:"
    echo_stderr "  target: the destination directory to sync to"
    echo_stderr "          can be a local path or a remote path in the form of user@host:path"
    echo_stderr "  --: separates the target from the rsync options"
    echo_stderr "  rsync options: additional options to pass to rsync"
    echo_stderr ""
    echo_stderr "Options:"
    echo_stderr "  -h: show this help message"
    echo_stderr ""
    echo_stderr "Example:"
    echo_stderr "  ${script_name} /media/backup/"
    echo_stderr "  ${script_name} remote_host:/media/backup/"
    echo_stderr "  ${script_name} /media/backup/ -- --dry-run"
    echo_stderr ""
    echo_stderr "Note:"
    echo_stderr "  The source directory is hardcoded to $SOURCE_DIR"
}

### Main function ###
main() {
    local target=""

    # Manage the command line arguments
    while getopts "h?" opt; do
      case "$opt" in
        h)
          usage
          exit 0
          ;;
        ?)
          usage
          exit 1
          ;;
      esac
    done
    shift $(expr $OPTIND - 1 )
    target="$1"
    shift
    [ "${1:-}" = "--" ] && shift
    additional_args="${@}"

    if [[ "$target" == "" ]]; then
        echo_stderr "Please provide a target."
        echo_stderr ""
        usage
        exit 1
    fi
    target="${target%/}/"

    log_enabled=false
    log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S).log"
    log_arg=""
    if [[ ! "$additional_args" =~ --dry-run|-n ]]; then
        log_enabled=true
        log_arg="--log-file=$log_file"
    fi

    echo "> source:        $SOURCE_DIR"
    echo "> target:        $target"
    if $log_enabled; then
      echo "> logging to:    $log_file"
    fi
    echo "> rsync options: $additional_args"

    mkdir -p "$CONFIG_DIR" "$LOG_DIR"

    rsync -avP \
      --stats \
      --human-readable \
      --exclude-from ~/.config/sync_home/excludes \
      $log_arg \
      $additional_args \
      "$SOURCE_DIR" "$target"

    if $log_enabled; then
      echo "> logged to: $log_file"
    fi
    echo "> done"
}

main "$@"
