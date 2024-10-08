#!/bin/bash

shopt -sq expand_aliases

source "$BASE16_SHELL/profile_helper.sh"

get_theme_name() {
	theme_file="$(basename $1)"
	theme_full_name="${theme_file%.*}"
	theme_name="${theme_full_name#base16-}"
	echo $theme_name
}

CURRENT_THEME_PATH="$(readlink -eq ~/.base16_theme)"
CURRENT_THEME_NAME="$(get_theme_name "$CURRENT_THEME_PATH")"

THEME_LIGHT=~/.config/base16-shell/scripts/base16-tomorrow.sh
THEME_DARK=~/.config/base16-shell/scripts/base16-tomorrow-night.sh

THEME_LIGHT_NAME="$(get_theme_name "$THEME_LIGHT")"
THEME_DARK_NAME="$(get_theme_name "$THEME_DARK")"


if [ "$CURRENT_THEME_NAME" == "$THEME_DARK_NAME" ]; then
		echo "Switching to light theme ($THEME_LIGHT_NAME)"
		export BASE16_THEME="$THEME_LIGHT_NAME"
		_base16 "$THEME_LIGHT" "$THEME_LIGHT_NAME"
		tmux source ~/.config/tmux/tinted-tmux/colors/base16-${THEME_LIGHT_NAME}.conf
else
		echo "Switching to dark theme ($THEME_DARK_NAME)"
		export BASE16_THEME="$THEME_LIGHT_NAME"
		_base16 "$THEME_DARK" "$THEME_DARK_NAME"
		tmux source ~/.config/tmux/tinted-tmux/colors/base16-${THEME_DARK_NAME}.conf
fi

echo "export BASE16_THEME=$BASE16_THEME" > ~/.config/shell/theme.sh
