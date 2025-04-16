#!/bin/bash
#
# This script does the install procedure to handle suspend and hibernate on a laptop using systemd.
# It sets up the systemd sleep configuration and logind configuration files.
# It also disable xfce4-power-manager to prevent it from handling suspend, hibernate, and lid close events.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

SYSTEMD_DIR="/etc/systemd"
SLEEP_CONFIG_FILE="sleep.conf.d/00-theo.conf"
LOGIND_CONFIG_FILE="logind.conf.d/00-theo.conf"

AUTOSTART_DIR="$HOME/.config/autostart"
XFCE4_POWER_MANAGER="xfce4-power-manager.desktop"
LIGHT_LOCKER="light-locker.desktop"

generate_autostart() {
  hidden="$1"
  # Generate the autostart file
  cat <<-EOF
	[Desktop Entry]
	Hidden=$hidden
	
	EOF
}

install() {
  tmpdir="$(mktemp -dt sleep-install-XXXXXXXXXX)"
  trap 'rm -rf "$tmpdir"' EXIT

  # Install systemd sleep configuration
  echo "> Checking $(basename "$SLEEP_CONFIG_FILE")"
  if ! diff -q "$SCRIPT_DIR/$SLEEP_CONFIG_FILE" "$SYSTEMD_DIR/$SLEEP_CONFIG_FILE" &>/dev/null; then
    echo -n "  "
    sudo cp -v "$SCRIPT_DIR/$SLEEP_CONFIG_FILE" "$SYSTEMD_DIR/$SLEEP_CONFIG_FILE"
    echo "  reloading systemd"
    sudo systemctl daemon-reload
    echo "  done"
  else
    echo "  already installed"
  fi

  # Install systemd logind configuration
  echo "> Checking $(basename "$LOGIND_CONFIG_FILE")"
  if ! diff -q "$SCRIPT_DIR/$LOGIND_CONFIG_FILE" "$SYSTEMD_DIR/$LOGIND_CONFIG_FILE" &>/dev/null; then
    echo -n "  "
    sudo cp -v "$SCRIPT_DIR/$LOGIND_CONFIG_FILE" "$SYSTEMD_DIR/$LOGIND_CONFIG_FILE"
    echo "  reloading systemd"
    sudo systemctl daemon-reload
    echo "  restarting systemd-logind"
    sudo systemctl restart systemd-logind
    echo "  done"
  else
    echo "  already installed"
  fi

  # Disable xfce4-power-manager power management handling
  # NOTE: keep it running for brightness control
  echo "> Checking xfce4-power-manager"
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -n -t bool -s true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-power-key -n -t bool -s true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-suspend-key -n -t bool -s true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-hibernate-key -n -t bool -s true
  echo "  configured"

  # Enable light-locker autostart
  echo "> Checking $LIGHT_LOCKER"
  generate_autostart "false" > "$tmpdir/$LIGHT_LOCKER"
  if ! diff -q "$tmpdir/$LIGHT_LOCKER" "$AUTOSTART_DIR/$LIGHT_LOCKER" &>/dev/null; then
    cat "$tmpdir/$LIGHT_LOCKER" > "$AUTOSTART_DIR/$LIGHT_LOCKER"
    echo "  updated"
  else
    echo "  already installed"
  fi

  if ! ps -C light-locker &>/dev/null; then
    light-locker &
    echo "  started"
  else
    echo "  already running"
  fi
}

main() {
  install
}

main "$@"
