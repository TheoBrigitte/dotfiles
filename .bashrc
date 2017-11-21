#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f ~/.bash_aliases ] && source ~/.bash_aliases
PS1="\[\033[01;34m\]\u@\h:\W\$\[\033[00m\] "

LOCAL_BIN="$HOME/.local/bin"
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN"
export EDITOR=vim
export VISUAL=$EDITOR
