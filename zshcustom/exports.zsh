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

  # Setup PostgreSQL, which is keg-only
  () {
    local postgresqlPath=$HOMEBREW_PREFIX/opt/postgresql@17

    if [[ -d $postgresqlPath/bin ]]; then
      path=($postgresqlPath/bin $path)
      pkg_config_path=($postgresqlPath/pkgconfig $pkg_config_path)
    fi
  }
fi

# Setup OrbStack
(( $+commands[orbctl] )) && [[ -r $HOME/.orbstack/shell/init.zsh ]] && source $HOME/.orbstack/shell/init.zsh

# Setup Google Cloud SDK
if (( $+commands[gcloud] )); then
  if [[ -n $HOMEBREW_PREFIX && -d $HOMEBREW_PREFIX/share/google-cloud-sdk ]]; then
    export CLOUD_SDK_ROOT=$HOMEBREW_PREFIX/share/google-cloud-sdk
  elif [[ -d /usr/share/google-cloud-sdk ]]; then
    export CLOUD_SDK_ROOT=/usr/share/google-cloud-sdk
  fi

  [[ -n $CLOUD_SDK_ROOT ]] && path+=$CLOUD_SDK_ROOT/bin
fi

# Setup usage of Ghostty from command line
if [[ -d "/Applications/Ghostty.app/Contents/MacOS" ]]; then
  path+="/Applications/Ghostty.app/Contents/MacOS"
fi

# Setup Android Studio development environment, if the SDK is installed
if [[ -d $HOME/Library/Android/sdk ]]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  path+=(
    $ANDROID_HOME/emulator
    $ANDROID_HOME/tools
    $ANDROID_HOME/tools/bin
    $ANDROID_HOME/platform-tools
  )
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

# Make Zed the default editor for commands that support the $EDITOR variable
export EDITOR="zed -w"
export KUBE_EDITOR="zed -w"
export K9S_EDITOR="zed -w"

# Enable persistent REPL history for `node`
export NODE_REPL_HISTORY=$HOME/.node_repl_history
# Allow 32³ entries (The default is 1000)
export NODE_REPL_HISTORY_SIZE=32768
# Use sloppy mode by default, matching the behaviour of web browsers
export NODE_REPL_MODE=sloppy

# Make Python use UTF-8 encoding for IO (stdin, stdout, and stderr)
export PYTHONIOENCODING="UTF-8"

# Avoid issues with `gpg`
# Ref: https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)
