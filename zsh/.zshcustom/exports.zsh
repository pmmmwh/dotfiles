#!/usr/bin/env zsh

# PATHS

typeset -U PATH path
typeset -U MANPATH manpath
typeset -TU PKG_CONFIG_PATH pkg_config_path

# Setup GNU utilities and OpenSSL
# Note: intentionally skiping GNU coreutils, GNU libtool and make - breaks GYP
if (( ${+commands[brew]} )); then
  if [[ -n ${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/^(coreutils|libtool|make)/libexec/gnubin(#qN) ]]; then
    path=(${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/^(coreutils|libtool|make)/libexec/gnubin $path)
  fi

  if [[ -n ${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/^(coreutils|libtool|make)/libexec/gnuman(#qN) ]]; then
    manpath=(${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/^(coreutils|libtool|make)/libexec/gnuman $manpath)
  fi

  if [[ -n ${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/postgresql@15/bin(#qN) ]]; then
    postgresqlPath=${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/postgresql@15

    path=($postgresqlPath/bin $path)
    pkg_config_path=($postgresqlPath/pkgconfig $pkg_config_path)
  fi
fi

# Setup usage of Ghostty from command line
path+="/Applications/Ghostty.app/Contents/MacOS"

# Setup usage of VSCode from command line
path+="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Setup Android Studio development environment
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=$HOME/Library/Android/sdk
path+=(
  $ANDROID_HOME/emulator
  $ANDROID_HOME/tools
  $ANDROID_HOME/tools/bin
  $ANDROID_HOME/platform-tools
)

# MISCELLANEOUS

# Set global configuration files for `git`
CURRENT_DIR="${"${(%):-%x}":A:h}"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0=core.attributesFile
export GIT_CONFIG_VALUE_0=$(echo $CURRENT_DIR/../../git/.gitattributes(:A))
export GIT_CONFIG_KEY_1=core.excludesFile
export GIT_CONFIG_VALUE_1=$(echo $CURRENT_DIR/../../git/.gitignore(:A))

# Use US English and UTF-8 encoding by default
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Make VSCode the default editor for commands that support the $EDITOR variable
export EDITOR="code -w"
export KUBE_EDITOR="code -w"
export K9S_EDITOR="code -w"

# Enable persistent REPL history for `node`
export NODE_REPL_HISTORY=$HOME/.node_repl_history
# Allow 32³ entries (The default is 1000)
export NODE_REPL_HISTORY_SIZE=32768
# Use sloppy mode by default, matching the behaviour of web browsers
export NODE_REPL_MODE=sloppy

# Make `pipx` use Python in installed via `mise`
export PIPX_DEFAULT_PYTHON=$(mise which python)
# Make Python use UTF-8 encoding for IO (stdin, stdout, and stderr)
export PYTHONIOENCODING="UTF-8"

# Avoid issues with `gpg` (installed via Homebrew)
# Ref: https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)
