#!/bin/bash

update-bootloader_command() {
  echo "> Starting systemd-boot update ..."

  # Check systemd-boot versions
  # Version currently booted from EFI application
  systemd_boot_version_booted="$(bootctl|awk '/Product:/ {print $3}')"
  # Version expected to be booted from EFI application
  systemd_boot_version_expected="$(bootctl|sed -n -E 's/.*\/EFI\/systemd\/systemd-bootx64.efi \(systemd-boot (.+)\)/\1/p')"
  # Version currently installed in the system
  systemd_boot_version_current="$(bootctl --version|head -n1|sed -n -E 's/.*\((.+)\)/\1/p')"

  error_msg=""
  if [[ "$systemd_boot_version_current" == "$systemd_boot_version_expected" ]]; then
    # If the currently installed version is the same as the expected version, it means systemd-boot is already up-to-date
    error_msg="${ORANGE}WARNING: systemd-boot is already up-to-date, do no update! Otherwise current fallback entry will be lost.${NO_COLOR}"
    display_current="${RED}${systemd_boot_version_current}${NO_COLOR}"
    display_expected="${RED}${systemd_boot_version_expected}${NO_COLOR}"
  else
    # If the currently installed version is different from the expected version, it means systemd-boot can be updated
    display_current="${GREEN}${systemd_boot_version_current}${NO_COLOR}"
    display_expected="${GREEN}${systemd_boot_version_expected}${NO_COLOR}"
  fi

  if [[ "$systemd_boot_version_booted" != "$systemd_boot_version_expected" ]]; then
    # If the currently booted version from EFI application is different from the expected version, it means systemd-boot was not booted from the expected version
    error_msg="${ORANGE}WARNING: systemd-boot was not booted from the expected version, do no update! Otherwise current fallback entry will be lost.${NO_COLOR}"
    display_booted="${RED}${systemd_boot_version_booted}${NO_COLOR}"
  else
    display_booted="${GREEN}${systemd_boot_version_booted}${NO_COLOR}"
  fi

  # Display versions
  echo -e "> systemd-boot versions"
  echo -e "  - Booted from EFI application      : $display_booted"
  echo -e "  - Expected  from EFI application   : $display_expected"
  echo -e "  - Currently installed in the system: $display_current"

  if [[ -n "$error_msg" ]]; then
    echo -e "\n> ${error_msg}"
    exit 1
  fi

  # Backup systemd-boot old EFI application files
  sudo cp -rvi "/boot/$SYSTEMD_DIR/"* "/boot/$SYSTEMD_OLD_DIR"

  # Update systemd-boot
  read -p "> Press [ENTER] to continue with systemd-boot update or [CTRL+C] to abort ..."
  echo "> Updating systemd-boot ..."
  sudo bootctl update

  echo "> Systemd-boot updated successfully."
}
