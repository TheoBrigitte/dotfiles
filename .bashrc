#
# ~/.bashrc
#
#----------------------------------------------------------------------------#
# Bash text colour specification:  \e[<STYLE>;<COLOUR>m
# (Note: \e = \033 (oct) = \x1b (hex) = 27 (dec) = "Escape")
# Styles:  0=normal, 1=bold, 2=dimmed, 4=underlined, 7=highlighted
# Colours: 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan, 37=white
#----------------------------------------------------------------------------#
function build_prompt() {
	local ex=$?

	local blue='\[\e[1;34m\]'
	local red='\[\e[1;31m\]'
	local reset='\[\e[0m\]'

	local exit_color="${blue}"
	[[ "$ex" -ne 0 ]] && exit_color="${red}"
	local exit_code="${exit_color}»${reset}"

	local date='[\D{%H:%M:%S}]'
	PS1="${exit_code} ${date} ${blue}\u@\h:\W ${reset}$(kube_ps1)${blue}\$${reset} "
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ssh keys
command -v keychain >/dev/null && \
  eval $(keychain --eval --quiet theo/id_rsa giantswarm/id_rsa)

# aliases
[ -r "$HOME/.config/bash/aliases" ] && source "$HOME/.config/bash/aliases"
[ -r "$HOME/.config/bash/functions" ] && source "$HOME/.config/bash/functions"

# completion
[ -r /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
[ -r "$HOME/.local/lib/azure-cli/az.completion" ] && source "$HOME/.local/lib/azure-cli/az.completion"


# fzf: fuzzy finder (CTRL+r)
[ -r /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -r /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

# prompt
KUBE_PS1_SYMBOL_ENABLE=false
PROMPT_COMMAND=""
[ -r "$HOME/.config/bash/kube-ps1.sh" ] && source "$HOME/.config/bash/kube-ps1.sh"
PROMPT_COMMAND="build_prompt;${PROMPT_COMMAND:-:}"

# environment variables
LOCAL_BIN="$HOME/.local/bin"
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN"
export EDITOR=vim
export VISUAL=$EDITOR

export GITHUB_TOKEN=$(cat "$HOME/secrets/theo/github.com-token")
export OPSCTL_GITHUB_TOKEN=$GITHUB_TOKEN

