#!/bin/bash

error="${RED}error${NO_COLOR}"

check_systemd() {
  echo -n "systemd-boot .......... "

  # Check if systemd-boot is installed
  efi_boot_var_name="$(efibootmgr --unicode | grep -F '\EFI\systemd-old\systemd-bootx64.efi' | awk '{ print $1 }')"
  if ! echo -e "$efi_boot_var_name" | grep -P '\*$' >/dev/null; then
    echo -e "$error - efi entry is not active"
    return
  fi

  # Check if systemd-boot old directory exists and get its version
  systemd_boot_version="$(strings /boot/EFI/systemd-old/systemd-bootx64.efi|grep -m1 '#### LoaderInfo: systemd-boot'|awk '{print $4}')"
  if [[ -z "$systemd_boot_version" ]]; then
    echo -e "$error - could not determine systemd-boot version"
    return
  fi

  echo -e "${GREEN}$systemd_boot_version${NO_COLOR}"
}

check_systemd_entry() {
  echo -n "systemd-boot entry .... "
  entry="/boot/loader/entries/$LOADER_ENTRY"
  if [[ ! -f "$entry" ]]; then
    echo -e "$error - $entry not found"
    return
  fi

  # Check if entry exists in systemd-boot
  if [[ "$(bootctl list --no-pager --json=short | jq -r '.[] | select(.id == "'"$LOADER_ENTRY"'") | objects != ""')" != "true" ]]; then
    echo -e "$error - entry not found in systemd-boot"
    return
  fi

  echo -e "${GREEN}ok${NO_COLOR}"
}

check_kernel() {
  echo -n "kernel ................ "

  linux_file="$(cat "/boot/loader/entries/$LOADER_ENTRY" | grep -P '^linux\s+'|awk '{print $2}')"
  initrd="$(cat "/boot/loader/entries/$LOADER_ENTRY" | grep -P '^initrd\s+'|awk '{print $2}')"
  linux_file="${linux_file#/}"  # remove leading slash
  initrd="${initrd#/}"          # remove leading slash
  if [[ ! -f "/boot/$linux_file" ]]; then
    echo -e "$error - /boot/$linux_file not found"
    return
  elif [[ ! -f "/boot/$initrd" ]]; then
    echo -e "$error - /boot/$initrd not found"
    return
  fi

  if ! file -bL "/boot/$linux_file" | grep -qF "$KERNEL_VERSION" 1>/dev/null; then
    echo -e "$error - /boot/$linux_file does not match expected version $KERNEL_VERSION"
    return
  fi

  echo -e "${GREEN}ok${NO_COLOR}"
}

status_command() {
  check_systemd
  check_systemd_entry
  check_kernel
}
