# Enable Powerlevel10k instant prompt.
# Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input
# (password prompts, [y/n] confirmations, etc.) must go above this block;
# everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup Homebrew - if it is available
if type brew &>/dev/null ; then
  # Cache Homebrew's prefix for the session
  export BREW_PREFIX=$(brew --prefix)

  typeset -U PATH path
  typeset -U FPATH fpath

  # Add Homebrew binaries to PATH
  path=($BREW_PREFIX/bin $path)
  # Enable auto-completion for Homebrew
  fpath=($BREW_PREFIX/share/zsh/site-functions $fpath)
fi

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
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random.
# Setting this variable when ZSH_THEME=random,
# will cause zsh to load a theme from this variable,
# instead of looking in ~/.oh-my-zsh/themes/.
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

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

# Use dd/mm/yyyy format for the command execution timestamp in the history command output
# This utilises `strftime` format specifications
# Ref: `man strftime`
HIST_STAMPS="%d/%m/%Y"

# Use ~/.zshcustom as the ZSH_CUSTOM folder
# (The default is "$ZSH/custom")
ZSH_CUSTOM=$HOME/.zshcustom

# Lazyload `nvm` so it won't slow down shell initialisation
NVM_LAZY_LOAD="true"
# Lazyload `nvm` on using these commands
NVM_LAZY_LOAD_EXTRA_COMMANDS=(
  serve
  yarn
)

# Load common useful plugins for macOS, Node.js and Python.
# Add wisely - too many plugins will slow down shell startup.
plugins=(
  aws
  commons
  docker
  gcloud
  # git # disabled because it mostly provides aliases
  nvm
  osx
  pipenv
  pyenv
  rbenv
  # thefuck # disabled because it requires installation beforehand
  urltools
  yarn
  zsh-completions
  zsh-nvm
)

# Initialise the auto-completion system to consume extra completions (for bash/zsh).
# We don't need to call `bashcompinit` or `compinit` here because oh-my-zsh does that for us.
autoload -Uz bashcompinit
autoload -Uz compinit

# Enable the oh-my-zsh framework
source $ZSH/oh-my-zsh.sh

# Enable the Powerlevel10k theme.
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Add tab completion for `pipx`
(( ${+commands[pipx]} )) && eval "$(register-python-argcomplete pipx)"

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards)
[ -e $HOME/.ssh/config ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for frequently used apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Music Safari iTerm SystemUIServer Terminal" killall
