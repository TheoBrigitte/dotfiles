#!/bin/bash
#
# This script does the install procedure to handle suspend and hibernate on a laptop using systemd.
# It sets up the systemd sleep configuration and logind configuration files.
# It also disable xfce4-power-manager to prevent it from handling suspend, hibernate, and lid close events.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

SYSTEMD_DIR="/etc/systemd"
SLEEP_CONFIG_FILE="sleep.conf.d/00-theo.conf"
LOGIND_CONFIG_FILE="logind.conf.d/00-theo.conf"

AUTOSTART_DIR="$HOME/.config/autostart"
XFCE4_POWER_MANAGER="xfce4-power-manager/xfce4-power-manager.desktop"

install() {
  echo "> Checking $(basename "$SLEEP_CONFIG_FILE")"
  if ! diff -q "$SCRIPT_DIR/$SLEEP_CONFIG_FILE" "$SYSTEMD_DIR/$SLEEP_CONFIG_FILE" &>/dev/null; then
    sudo cp -v "$SCRIPT_DIR/$SLEEP_CONFIG_FILE" "$SYSTEMD_DIR/$SLEEP_CONFIG_FILE"
    echo "  reloading systemd"
    sudo systemctl daemon-reload
    echo "  done"
  else
    echo "  already installed"
  fi

  echo "> Checking $(basename "$LOGIND_CONFIG_FILE")"
  if ! diff -q "$SCRIPT_DIR/$LOGIND_CONFIG_FILE" "$SYSTEMD_DIR/$LOGIND_CONFIG_FILE" &>/dev/null; then
    sudo cp -v "$SCRIPT_DIR/$LOGIND_CONFIG_FILE" "$SYSTEMD_DIR/$LOGIND_CONFIG_FILE"
    echo "  reloading systemd"
    sudo systemctl daemon-reload
    echo "  restarting systemd-logind"
    sudo systemctl restart systemd-logind
    echo "  done"
  else
    echo "  already installed"
  fi

  xfce4_power_manager_file="$(basename "$XFCE4_POWER_MANAGER")"
  echo "> Checking $xfce4_power_manager_file"
  if ! diff -q "$SCRIPT_DIR/$XFCE4_POWER_MANAGER" "$AUTOSTART_DIR/$xfce4_power_manager_file" &>/dev/null; then
    cp -v "$SCRIPT_DIR/$XFCE4_POWER_MANAGER" "$AUTOSTART_DIR/$xfce4_power_manager_file"
  else
    echo "  already installed"
  fi
  echo -n "  "
  xfce4-power-manager --quit
}

main() {
  install
}

main "$@"
