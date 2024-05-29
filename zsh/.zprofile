# Disable filename expansion for `=`
setopt noequals

# Enable case-insensitive globing (used in pathname expansion)
setopt nocaseglob

# Enable extended globing for qualifiers
setopt extendedglob

# Use ~/.zshcustom as the ZSH_CUSTOM folder
# (The default is "$ZSH/custom")
export ZSH_CUSTOM=$HOME/.zshcustom

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

# Enable Homebrew
[[ -n $BREW_LOCATION ]] && eval "$("$BREW_LOCATION" shellenv)"
unset BREW_LOCATION

# Load library files
for libraryFile ($ZSH_CUSTOM/*.zsh); do
  source $libraryFile
done

# Enable shims from `mise`
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)"
