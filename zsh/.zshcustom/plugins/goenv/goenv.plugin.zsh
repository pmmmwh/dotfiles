#!/usr/bin/env zsh

_zsh_goenv_load() {
  # Export `goenv` related environment variables
  if [[ -z "$GOENV_ROOT" ]]; then
    export GOENV_ROOT=$HOME/.goenv
  fi

  eval "$(goenv init -)"
}

# Load `goenv` if it is installed
if (( ${+commands[goenv]} )); then
  _zsh_goenv_load
fi
