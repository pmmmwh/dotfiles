#!/usr/bin/env zsh

_zsh_fnm_load() {
  eval "$(fnm env)"
}

# Load `fnm` if it is installed
if (( ${+commands[fnm]} )); then
  _zsh_fnm_load
fi
