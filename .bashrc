#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ssh keys
command -v keychain >/dev/null && \
  eval $(keychain --eval --quiet theo/id_rsa giantswarm/id_rsa)

# bash aliases
[ -r "$HOME/.config/bash/aliases" ] && source "$HOME/.config/bash/aliases"

# bash completion
[ -r "$HOME/.local/lib/azure-cli/az.completion" ] && source "$HOME/.local/lib/azure-cli/az.completion"
[ -r "$HOME/.config/bash/gsctl-completion" ] && source "$HOME/.config/bash/gsctl-completion"
[ -r "$HOME/.config/bash/kubectl-completion" ] && source "$HOME/.config/bash/kubectl-completion"
[ -r "$HOME/.config/bash/opsctl-completion" ] && source "$HOME/.config/bash/opsctl-completion"

# bash prompt
PS1="\[\033[01;34m\]\u@\h:\W\$\[\033[00m\] "

# go
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"

LOCAL_BIN="$HOME/.local/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN"
export EDITOR=vim
export VISUAL=$EDITOR

export GITHUB_TOKEN=$(cat "$HOME/secrets/theo/github.com-token")
export OPSCTL_GITHUB_TOKEN=$GITHUB_TOKEN

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
