#!/bin/bash
# This script toggles between light and dark themes for base16-shell.
# It assumes you have two themes: one for light and one for dark.
# Usage: ./switch-theme.sh

shopt -sq expand_aliases

SHELL_THEME_LIGHT=~/.config/base16-shell/scripts/base16-tomorrow.sh
SHELL_THEME_DARK=~/.config/base16-shell/scripts/base16-tomorrow-night.sh

DESKTOP_THEME_LIGHT="WhiteSur-Light-solid"
DESKTOP_THEME_DARK="WhiteSur-Dark-solid"

ICON_THEME_LIGHT="WhiteSur-light"
ICON_THEME_DARK="WhiteSur-dark"

source "$BASE16_SHELL/profile_helper.sh"

get_theme_name() {
  local theme_file="$(basename $1)"
  local theme_full_name="${theme_file%.*}"
  local theme_name="${theme_full_name#base16-}"
  echo $theme_name
}

switch_shell_theme() {
  local theme_name="$1"
  local theme_path="$2"

  export BASE16_THEME="$theme_name"
  _base16 "$theme_path" "$theme_name"
  echo "export BASE16_THEME=$BASE16_THEME" > ~/.config/shell/theme.sh
}

switch_tmux_theme() {
  local theme_name="$1"

  ln -fsr ~/.config/tmux/tinted-tmux/colors/base16-${theme_name}.conf ~/.config/tmux/theme.conf
  tmux source ~/.config/tmux/theme.conf
}

switch_desktop_theme() {
  local desktop_theme_name="$1"
  local icon_theme_name="$2"

  xfconf-query --channel xsettings --property /Net/ThemeName --create --type string --set "$desktop_theme_name"
  xfconf-query --channel xfwm4 --property /general/theme --create --type string --set "$desktop_theme_name"
  xfconf-query --channel xsettings --property /Net/IconThemeName --create --type string --set "$icon_theme_name"
}

main() {
  local current_theme_path="$(readlink -eq ~/.base16_theme)"
  local current_theme_name="$(get_theme_name "$current_theme_path")"

  local shell_theme_light_name="$(get_theme_name "$SHELL_THEME_LIGHT")"
  local shell_theme_dark_name="$(get_theme_name "$SHELL_THEME_DARK")"

  local shell_theme_name=""
  local shell_theme_path=""
  local desktop_theme_name=""
  local icon_theme_name=""

  if [ "$current_theme_name" == "$shell_theme_dark_name" ]; then
    echo "Switching to light theme ($shell_theme_light_name)"
    shell_theme_name="$shell_theme_light_name"
    shell_theme_path="$SHELL_THEME_LIGHT"
    desktop_theme_name="$DESKTOP_THEME_LIGHT"
    icon_theme_name="$ICON_THEME_LIGHT"
  else
    echo "Switching to dark theme ($shell_theme_dark_name)"
    shell_theme_name="$shell_theme_dark_name"
    shell_theme_path="$SHELL_THEME_DARK"
    desktop_theme_name="$DESKTOP_THEME_DARK"
    icon_theme_name="$ICON_THEME_DARK"
  fi

  xfce4-appearance-settings &
  xfce4_appearance_settings_pid=$!
  sleep 0.5  # Give the settings dialog time to open

  switch_shell_theme "$shell_theme_name" "$shell_theme_path"
  switch_tmux_theme "$shell_theme_name"
  switch_desktop_theme "$desktop_theme_name" "$icon_theme_name"

  sleep 0.5  # Allow time for the changes to take effect
  kill "$xfce4_appearance_settings_pid"
}

main "$@"
