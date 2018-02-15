#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ssh keys
eval $(keychain --eval --quiet theo_id_rsa gs_id_rsa)

# bash aliases
[ -f "$HOME/.config/bash/aliases" ] && source "$HOME/.config/bash/aliases"

# bash completion
[ -f "$HOME/.local/lib/azure-cli/az.completion" ] && source "$HOME/.local/lib/azure-cli/az.completion"
[ -f "$HOME/.config/bash/gsctl-completion" ] && source "$HOME/.config/bash/gsctl-completion"
[ -f "$HOME/.config/bash/kubectl-completion" ] && source "$HOME/.config/bash/kubectl-completion"
[ -f "$HOME/.config/bash/opsctl-completion" ] && source "$HOME/.config/bash/opsctl-completion"

# bash prompt
PS1="\[\033[01;34m\]\u@\h:\W\$\[\033[00m\] "

# go
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"

local LOCAL_BIN="$HOME/.local/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN"
export EDITOR=vim
export VISUAL=$EDITOR

export GITHUB_TOKEN=$(cat .secrets/token.theo.github.com)
export OPSCTL_GITHUB_TOKEN=$GITHUB_TOKEN
