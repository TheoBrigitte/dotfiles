#
# ~/.bashrc
#
#----------------------------------------------------------------------------#
# Bash text colour specification:  \e[<STYLE>;<COLOUR>m
# (Note: \e = \033 (oct) = \x1b (hex) = 27 (dec) = "Escape")
# Styles:  0=normal, 1=bold, 2=dimmed, 4=underlined, 7=highlighted
# Colours: 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan, 37=white
#----------------------------------------------------------------------------#
build_prompt() {

	local blue='\001\e[1;34m\002'
	local red='\001\e[1;31m\002'
	local reset='\001\e[00m\002'
	exit_color=${blue}

	exit_code() {
		local ex=$?
		local blue='\001\e[1;34m\002'
		local red='\001\e[1;31m\002'
		local reset='\001\e[00m\002'
		[[ "$ex" -ne 0 ]] && exit_color="${red}"
	}

	local date='[\D{%H:%M:%S}]'
	PS1="\$(exit_code)${blue}\u@\h:\W${reset} \$(kube_ps1)${exit_color}\$${reset} "
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# common
source "$HOME/.config/shell/common"

# completion
source /usr/share/bash-completion/bash_completion

# fzf: fuzzy finder (CTRL+r)
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash ~/.fzf.bash

# prompt
build_prompt

