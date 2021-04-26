autoload -Uz +X bashcompinit compinit
bashcompinit
compinit

export ZSH=$HOME/.config/zsh/oh-my-zsh

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

fpath=($HOME/.config/zsh/completion $fpath)
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
# Prevent duplicate entries from being saved to history.
HISTCONTROL=ignoredups:ignorespace
DISABLE_AUTO_UPDATE=true
DISABLE_MAGIC_FUNCTIONS=true

source $ZSH/oh-my-zsh.sh

# User configuration

setopt autocd extendedglob sharehistory

zstyle ':completion:*' rehash true

# Do not expand #
unsetopt EXTENDED_GLOB
unsetopt nomatch

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# common
source "$HOME/.config/shell/common"
zstyle ':urlglobber' url-other-schema
ZSH_HISTORY_PROJ="${HOME}/.zsh_history_sync"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"

# completion (broken ones only)
source "$HOME/.config/zsh/completion/_helm"
source "$HOME/.config/zsh/completion/_minikube"

# fzf: fuzzy finder (CTRL+r)
source "/usr/share/fzf/key-bindings.zsh"
source "/usr/share/fzf/completion.zsh"

# autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

cdpath=(
    $HOME/src/github.com/giantswarm
    $HOME/src/github.com/TheoBrigitte
    $HOME/projects/giantswarm
    $HOME/projects
)

# prompt
local blue='%{[1;36m%}'
local red='%{[1;31m%}'
local c="%(?.${blue}.${red})"
PROMPT="${blue}%1~%{$reset_color%} \$(kube_ps1)${c}%(!.#.$)%f%{$reset_color%} "
