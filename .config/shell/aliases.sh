[[ "$OSTYPE" == "linux-gnu" ]] && LS_ARGS="--color=auto"
[[ "$OSTYPE" == "darwin"* ]] && LS_ARGS="-G"
alias ls="ls $LS_ARGS"

command -pv open &>/dev/null || alias open='xdg-open'

# irc
alias irc='ssh -t theo@higgs screen -r irc'

# kubectl
alias k="kubectl"
alias kx="kubectx"
alias kns="kubens"
alias koff="kubeoff -g"
alias kon="kubeon -g"
alias kc="kubectl config current-context"
alias kgp="kubectl get pods"
alias kss="kns kube-system"
alias ks='kubectl -n=kube-system'
alias km='kubectl -n=monitoring'
alias kd='kubectl -n=default'
alias kv='ln -fsv $(ls -1 ~/.local/bin/kubectlv*|fzf) ~/.local/bin/kubectl'

# flux
alias fv='ln -fsv $(ls -1 ~/.local/bin/fluxv*|fzf) ~/.local/bin/flux'

# git
alias ga='git add'
alias gap='git add -p'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias gam='git commit --amend'
alias gamm='git commit --amend --no-edit'
alias gco='git checkout'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gp='git push'
alias gpn='git push -u origin HEAD'
alias gpr='git push --rebase'
alias grc='git rebase --continue'
alias gul='git pull'
alias gf='git fetch -vp'
alias gcountcommits="git shortlog -sn"
#alias gcountlines='git ls-files -z | xargs -0n1 git blame -w | perl -n -e \'/^.*\((.*?)\s*[\d]{4}/; print $1,"\n"\' | sort -f | uniq -c | sort -n'
alias gl='git log'
alias gll='git log --decorate --graph --oneline'
alias glp='git log -p'
alias gls='gll --stat'
alias gpf='gp -f'
alias gds='git diff --stat $(git merge-base --fork-point origin/master)'
alias gra='git remote set-head origin --auto'

# giantswarm
alias kg='kubectl -n=giantswarm'
alias kf='kubectl -n=flux-giantswarm'
alias glc='kubectl gs get clusters -A'
alias gi='cd $GOPATH/src/github.com/giantswarm'
alias oli='opsctl list installations'
alias pmo='cd -P prometheus-meta-operator'
alias vpa='cd -P vertical-pod-autoscaler-app'
alias obop='cd observability-operator'
alias mcb="cd management-cluster-bases"

# text
alias standup="vim +'normal G' +'r!date' +'normal o' +startinsert ~/standup.txt"
alias todo="vim ~/TODO.md"

# other
alias ll='luigi --color|less -R'
alias less='less -FXI'
alias gok="go build && go test ./... && echo OK"
alias tm="tmux new -s default"
alias watch="watch "
alias clip="xclip -sel clip -i"
alias theo='cd $GOPATH/src/github.com/TheoBrigitte'
alias vi='nvim'
alias vim='nvim'
alias bl='kubectl neat | bat -lyaml'
alias watch='watch '
alias please='sudo'
alias hell='helm'
alias switch-theme="switch-theme.sh; source ~/.config/shell/theme.sh"
