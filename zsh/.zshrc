# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

# Disable filename expansion for `=`
setopt noequals

# Enable case-insensitive globing (used in pathname expansion)
setopt nocaseglob

# Enable extended globing for qualifiers
setopt extendedglob

# Use the text that has already been typed as the prefix for searching through commands
# (i.e. enables a more intelligent Up/Down behavior)
bindkey "\e[A" history-search-backward
bindkey "\e[B" history-search-forward

# Path to the oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load ---
# if set to "random", it will load a random theme each time oh-my-zsh is loaded,
# in which case, to know which specific one was loaded, run: echo $RANDOM_THEME.
# Ref: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# This changes how often oh-my-zsh is auto-updated (in days)
# (The default is 13)
export UPDATE_ZSH_DAYS=7

# Uncomment the following line if pasting URLs and other text is messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Use yyyy-mm-dd format for the command execution timestamp in the history command output
# This utilises `strftime` format specifications
# Ref: `man strftime`
HIST_STAMPS="%Y-%m-%d"

# Use ~/.zshcustom as the ZSH_CUSTOM folder
# (The default is "$ZSH/custom")
ZSH_CUSTOM=$HOME/.zshcustom

# Load common useful plugins for macOS, Node.js and Python.
# Add wisely - too many plugins will slow down shell startup.
plugins=(
  commons
  docker
  evalcache
  fnm
  gcloud
  pipx
  poetry
  rust
  urltools
  zsh-lazyload
)

# Initialise the auto-completion system to consume extra completions (for bash/zsh).
# We don't need to call `bashcompinit` or `compinit` here because oh-my-zsh does that for us.
autoload -Uz bashcompinit
autoload -Uz compinit

# Initialise paths
typeset -U PATH path
typeset -U FPATH fpath

# Add `~/bin`, `~/.local/bin` and `/opt/starship/bin` to $PATH,
# ensures any binary dependencies of plugins get populated from Homebrew.
path=($HOME/bin $HOME/.local/bin /opt/starship/bin $path)

# Setup extra ZSH completions
fpath=($ZSH_CUSTOM/plugins/zsh-completions/src $fpath)

# Setup Homebrew completions
if (( ! $+commands[brew] )); then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    export BREW_LOCATION="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    export BREW_LOCATION="/usr/local/bin/brew"
  fi
fi
if [[ -n $BREW_LOCATION ]]; then
  fpath=(${BREW_LOCATION:h:h}/share/zsh/site-functions $fpath)
fi

# Enable the oh-my-zsh framework
source $ZSH/oh-my-zsh.sh

# Enable the Starship theme
_evalcache starship init zsh

# Enable Homebrew
[[ -n $BREW_LOCATION ]] && _evalcache "$BREW_LOCATION" shellenv
unset BREW_LOCATION

# Initialize tools (with lazyload if possible)
(( $+commands[atuin] )) && _evalcache atuin init zsh
# Always load Node.js (compat for global tools)
(( $+commands[fnm] )) && _evalcache fnm env
# Check if Python is already initialized (compat for virtual env)
(( ! $+commands[python] && $+commands[pyenv] )) && lazyload jupyter keyring pip pip3 poetry pyenv python python3 -- '_evalcache pyenv init -'
(( $+commands[goenv] )) && lazyload go goenv -- '_evalcache goenv init -'
(( $+commands[rbenv] )) && lazyload bundle bundler gem ruby -- '_evalcache rbenv init -'
(( $+commands[rustup-init] )) && lazyload cargo rustc rustup -- 'source $HOME/.cargo/env'

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards)
[ -e $HOME/.ssh/config ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for frequently used apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Music Safari SystemUIServer Terminal wezterm-gui" killall

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
