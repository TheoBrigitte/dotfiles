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

# bash aliases
[ -r "$HOME/.config/bash/aliases" ] && source "$HOME/.config/bash/aliases"

# bash completion
[ -r /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
[ -r "$HOME/.local/lib/azure-cli/az.completion" ] && source "$HOME/.local/lib/azure-cli/az.completion"
[ -r "$HOME/.config/bash/gsctl-completion" ] && source "$HOME/.config/bash/gsctl-completion"
[ -r "$HOME/.config/bash/kubectl-completion" ] && source "$HOME/.config/bash/kubectl-completion"
[ -r "$HOME/.config/bash/opsctl-completion" ] && source "$HOME/.config/bash/opsctl-completion"

# bash prompt
export PROMPT_COMMAND=build_prompt

# fzf: fuzzy finder (CTRL+r)
[ -r /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -r /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

# golang
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"

# kubernetes
KUBE_PS1_SYMBOL_ENABLE=false
[ -r "$HOME/.config/bash/kube-ps1.sh" ] && source "$HOME/.config/bash/kube-ps1.sh"

LOCAL_BIN="$HOME/.local/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN"
export EDITOR=vim
export VISUAL=$EDITOR

export GITHUB_TOKEN=$(cat "$HOME/secrets/theo/github.com-token")
export OPSCTL_GITHUB_TOKEN=$GITHUB_TOKEN

