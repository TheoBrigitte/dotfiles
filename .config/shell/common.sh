source "$HOME/.config/shell/functions.sh"

# ssh keys
ssh-add -l &>/dev/null || ssh-add "$HOME/.ssh/theo_rsa" "$HOME/.ssh/giantswarm_rsa" &>/dev/null

# aliases
source "$HOME/.config/shell/aliases.sh"

# azure-cli completion
[ -f "$HOME/.local/lib/azure-cli/az.completion" ] &&\
	source "$HOME/.local/lib/azure-cli/az.completion"

# kubernetes prompt
export KUBE_PS1_SYMBOL_ENABLE=false
export KUBE_TMUX_SYMBOL_ENABLE=false
source "$HOME/.config/shell/kube-ps1.sh"

# environment variables
LOCAL_BIN="$HOME/.local/bin"
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$LOCAL_BIN:$GOBIN:$HOME/.krew/bin:$HOME/.cargo/bin:$HOME/projects/atlas-hacks/hack/bin:$HOME/.local/share/solana/install/active_release/bin"
export EDITOR=nvim
export VISUAL=$EDITOR
export GPG_TTY=$(tty)

export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'
#export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
#export FZF_DEFAULT_COMMAND='rg --files --hidden'
#export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
#export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
#--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
export FZF_DEFAULT_OPTS='
--color info:108,prompt:109,spinner:108,pointer:168,marker:168
'

export GITHUB_TOKEN=$(cat "$HOME/secrets/theo/github.com-token")
export OPSCTL_GITHUB_TOKEN=$GITHUB_TOKEN
export LEVIATHAN_GITHUB_TOKEN=$GITHUB_TOKEN
export OPSCTL_OPSGENIE_TOKEN=$(cat "$HOME/secrets/giantswarm/opsgenie_token")
export HEARTBEATCTL_TOKEN=$OPSCTL_OPSGENIE_TOKEN
export OPSCTL_GPG_PASSWORD=$(cat "$HOME/secrets/giantswarm/gpg_password")
export GRAFANA_API_KEY=$(cat "$HOME/secrets/giantswarm/grafana_key")
export CIRCLECI_TOKEN=$(cat "$HOME/secrets/theo/circleci_token")
export LPASS_DISABLE_PINENTRY=1
export OPSCTL_SLACK_TOKEN=$(cat "$HOME/secrets/giantswarm/slack_token")
export PAGERDUTY_API_TOKEN=$(cat "$HOME/secrets/giantswarm/pagerduty_token")

#export QT_STYLE_OVERRIDE=gtk
export QT_SELECT=qt5

# colors
export BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
		source "$BASE16_SHELL/profile_helper.sh"
# current terminal theme is set at ~/.base16_theme
# change it with : base16_<theme> command
# e.g. base16_horizon-terminal-dark
