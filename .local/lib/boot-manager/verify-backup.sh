#!/bin/bash

set -eu

verify_command() {
  echo "> Checking backup consistency ..."

  # Configuration
  if [[ -z "$BACKUP_DIR" ]]; then
      echo "Error: BACKUP_DIR is not set."
      exit 1
  fi

  # Create temporary backup
  TMP_BACKUP_DIR="$(mktemp --tmpdir -d boot-backup.XXXXXX)"
  backup_command "$TMP_BACKUP_DIR"

  # Compare backups, backup include a checksum of the files, so if files are identical, the backup should be identical too
  if ! diff -r "$TMP_BACKUP_DIR" "$BACKUP_DIR" 1>/dev/null; then
      echo "> Differences found between $TMP_BACKUP_DIR and $BACKUP_DIR"
      echo "> To view differences, run:"
      echo "  diff -r $TMP_BACKUP_DIR $BACKUP_DIR"
      exit 1
  fi

  echo "> No differences found. Backup is consistent."
  rm -rf "$TMP_BACKUP_DIR"
}
