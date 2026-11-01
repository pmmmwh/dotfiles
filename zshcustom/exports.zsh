#!/usr/bin/env zsh

# PATHS

# Initialise path variables and ensure uniqueness
typeset -U PATH path
typeset -U MANPATH manpath
typeset -TU PKG_CONFIG_PATH pkg_config_path

# Add `~/bin` and `~/.local/bin` to $PATH,
# ensures any binary dependencies of plugins get populated.
path=($HOME/bin $HOME/.local/bin $path)

# Add  `/usr/sbin` and `/sbin` to $PATH -
# macOS `path_helper` populates these, but only for login shells
path+=(/usr/sbin /sbin)

# Find the Homebrew prefix -
# packages are installed by `mise` so `brew` might not be available
for brewPrefixCandidate in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [[ -d $brewPrefixCandidate/Cellar ]]; then
    export HOMEBREW_PREFIX=$brewPrefixCandidate
    break
  fi
done
unset brewPrefixCandidate

# Setup Homebrew paths
if [[ -n $HOMEBREW_PREFIX ]]; then
  path=($HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path)
  manpath=($HOMEBREW_PREFIX/share/man $manpath)
fi

# Setup Google Cloud SDK
if (( $+commands[gcloud] )); then
  if [[ -n $HOMEBREW_PREFIX && -d $HOMEBREW_PREFIX/share/google-cloud-sdk ]]; then
    export CLOUD_SDK_ROOT=$HOMEBREW_PREFIX/share/google-cloud-sdk
  elif [[ -d /usr/share/google-cloud-sdk ]]; then
    export CLOUD_SDK_ROOT=/usr/share/google-cloud-sdk
  fi

  [[ -n $CLOUD_SDK_ROOT ]] && path+=$CLOUD_SDK_ROOT/bin
fi

# MISCELLANEOUS

# Set global configuration files for `git`
() {
  local gitConfigDir=${${(%):-%x}:A:h}/../git
  gitConfigDir=${gitConfigDir:A}
  export GIT_CONFIG_COUNT=2
  export GIT_CONFIG_KEY_0=core.attributesFile
  export GIT_CONFIG_VALUE_0=$gitConfigDir/.gitattributes
  export GIT_CONFIG_KEY_1=core.excludesFile
  export GIT_CONFIG_VALUE_1=$gitConfigDir/.gitignore
}
# Disable prompt for commit message on merge
export GIT_MERGE_AUTOEDIT=no

# Use US English and UTF-8 encoding by default
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Make Zed the default editor for commands that support the $EDITOR variable,
# falling back to Vim where Zed is not installed (e.g. on a server)
() {
  local editor=vim
  (( $+commands[zed] )) && editor="zed -w"
  export EDITOR=$editor
  export KUBE_EDITOR=$editor
  export K9S_EDITOR=$editor
}

# Enable persistent REPL history for `node`
export NODE_REPL_HISTORY=$HOME/.node_repl_history
# Allow 32³ entries (The default is 1000)
export NODE_REPL_HISTORY_SIZE=32768
# Use sloppy mode by default, matching the behaviour of web browsers
export NODE_REPL_MODE=sloppy

# Make Python use UTF-8 encoding for IO (stdin, stdout, and stderr)
export PYTHONIOENCODING="UTF-8"
