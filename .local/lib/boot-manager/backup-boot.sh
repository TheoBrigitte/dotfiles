#!/bin/bash

backup_command() {
  # Ensure BACKUP_DIR is set
  BACKUP_DIR="${1:-$BACKUP_DIR}"
  if [[ -z "$BACKUP_DIR" ]]; then
    echo "Error: BACKUP_DIR is not set."
    exit 1
  fi

  echo "> Starting boot backup in $BACKUP_DIR ..."


  # Do not run as root
  if [[ "$(id -u)" == 0 ]] || [[ "$EUID" -eq 0 ]]; then
    echo "Error: This script should not be run as root."
    exit 1
  fi

  # Delete old backup if exists
  echo "> Cleaning up old boot backup ..."
  rm -r "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR/boot"

  # Dump efibootmgr status
  echo "> Exporting efibootmgr status ..."
  mkdir -p "$BACKUP_DIR/info"
  efibootmgr --unicode > "$BACKUP_DIR/info/efibootmgr.txt"

  # Backup EFI boot variables
  echo "> Backing up efiboot entries ..."
  mkdir -p "$BACKUP_DIR/efivar"
  efi_boot_var_name="$(cat "$BACKUP_DIR/info/efibootmgr.txt" | grep -F '\EFI\systemd-old\systemd-bootx64.efi' | awk '{ print $1 }')"
  if ! echo "$efi_boot_var_name" | grep -P '\*$' >/dev/null; then
    echo "Error: systemd-boot old entry is not active. Aborting backup."
    exit 1
  fi
  efi_boot_var_name="${efi_boot_var_name%\*}"  # remove trailing '*'
  efi_boot_var_guid="$(efivar -l | grep -P '\-'"$efi_boot_var_name"'$')"
  efi_bootorder_var_guid="$(efivar -l | grep -P '\-BootOrder$')"

  efivar -n "$efi_boot_var_guid" -e "$BACKUP_DIR/efivar/$efi_boot_var_guid"
  efivar -n "$efi_bootorder_var_guid" -e "$BACKUP_DIR/efivar/$efi_bootorder_var_guid"

  # Backup current loader entry and associated files
  echo "> Backing up /boot files ..."
  linux_file="$(cat "/boot/loader/entries/$LOADER_ENTRY" | grep -P '^linux\s+'|awk '{print $2}')"
  initrd="$(cat "/boot/loader/entries/$LOADER_ENTRY" | grep -P '^initrd\s+'|awk '{print $2}')"
  linux_file="${linux_file#/}"  # remove leading slash
  initrd="${initrd#/}"          # remove leading slash
  cd /boot
  cp --parents -r -t "$BACKUP_DIR/boot/" \
    "loader/loader.conf" \
    "loader/entries/$LOADER_ENTRY" \
    "$linux_file" \
    "$initrd" \
    "$SYSTEMD_OLD_DIR"
  cd - 1>/dev/null

  # Save loader entry metadata to assess the entry exists in systemd-boot
  bootctl list --json=short --no-pager | jq '.[] | select(.id == "'$LOADER_ENTRY'")' > "$BACKUP_DIR/info/loader_entry.json"

  # Generate checksums for all files in the backup
  cd "$BACKUP_DIR"
  find . -type f -print | sort | xargs sha256sum | tee "$BACKUP_DIR/sha256sums.txt" 1>/dev/null

  echo "> Backup completed successfully."
}
