#!/usr/bin/env zsh

# Bind Up and down arrow to searching upwards with the matching content
# before the cursor
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# set terminal color if not TMUX
# Reference: https://unix.stackexchange.com/questions/139082/zsh-set-term-screen-256color-in-tmux-but-xterm-256color-without-tmux
[[ $TMUX = "" ]] && export TERM="xterm-256color"

# Get rid of duplicate values in path
typeset -aU path

# Initialize the path
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TIMEFMT=$'\t%E real,\t%U user,\t%S sys'

# history settings
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.zhistory
HISTSIZE=4096
SAVEHIST=4096

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#DISABLE_AUTO_TITLE="true"

#powerline-daemon -q
ZSH_THEME=powerlevel10k/powerlevel10k

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='\uf0da'
#POWERLEVEL9K_VCS_GIT_ICON='\ue60a'

POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='red'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
#POWERLEVEL9K_VCS_UNTRACKED_ICON='?'


POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status dir vcs)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time background_jobs virtualenv rbenv rvm)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(background_jobs virtualenv rbenv rvm)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

#POWERLEVEL9K_CUSTOM_TIME_FORMAT="%D{\uf017 %H:%M:%S}"
POWERLEVEL9K_TIME_FORMAT="%D{\uf017 %H:%M \uf073 %d.%m.%y}"

# Only show status on failure
POWERLEVEL9K_STATUS_VERBOSE=false

DEFAULT_USER="apostolos"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

 #Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
#
# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git                       # Adds git aliases like gcc - /git
  pip                       # Adds autocomplete to pip
  dotenv                    # Automatically sources .env files
  colored-man-pages         # Colors man pages
  zsh-interactive-cd        # Adds fzf cd completion
  bazel                     # Adds Autocomplete for bazel
  wd                        # Adds wd tool
  ripgrep                   # Adds autocompletion for rg
  docker                    # Adds autocompletion for docker
  rails                     # Adds autocompletion for rails as well as aliases
  zsh-autosuggestions       # Add autosuggestions to Oh My Zsh
  zsh-syntax-highlighting   # Add syntax highlighting
)

#plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'

stty -ixon

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# Add home bin
export PATH=$HOME/bin:$PATH

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Functions
#function cdd() {
    #if [ $# -eq 0 ]; then
        #cdd-helper --help;
    #elif [ ${1:0:1} != "-" ] && [ $1 != "add" ] && [ $1 != "rm" ];
    #then
        #DIR=`cdd-helper $@ -p`;
        #if [[ ! -z $DIR ]]
        #then
            #cd "$DIR";
        #fi
    #else
        #cdd-helper $@;
    #fi
#}

function cs() {
    if [ $# -eq 0  ]; then
        cd && ls;
    else
        cd "$*" && ls;
    fi
}
alias cd='cs'

function math() {
    args="$@"
    python3 -c "print($args)"
}

# Secureframe Stuff
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export NVM_DIR="$HOME/.nvm"
eval "$(direnv hook zsh)"
eval "$(nodenv init -)"

# Autocorrect Disabling
alias bundle="nocorrect bundle"
alias doppler="nocorrect doppler"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
