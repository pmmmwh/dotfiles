#!/usr/bin/env zsh

logger() {
  local variant="${1:-info}"
  local message="${2:-}"

  if [ -z "$message" ]; then
    return
  fi

  case "$variant" in
    info)
      printf "\033[34m%-8s\033[0m %s\n" "info" "$message"
      ;;
    success)
      printf "\033[32m%-8s\033[0m %s\n" "success" "$message"
      ;;
    warning)
      printf "\033[33m%-8s\033[0m %s\n" "warning" "$message"
      ;;
    error)
      printf "\033[31m%-8s\033[0m %s\n" "error" "$message"
      ;;
  esac
}

elevate() {
  logger "info" "Requesting administrator credentials for setup ..."

  # Ask for the elevated rights with administrator password upfront
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until the script has finished
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

prompt() {
  unset PROMPT_PROCEED

  if [ -n "${1:-}" ]; then
    logger "info" "$1"
  fi

  local message
  message=$(logger "warning" "Please enter your choice (Auto-continue with 'Y' in 10s) [y/N] ")
  if ! read -k 1 -t 10 "?$message" || [[ $REPLY =~ ^[Yy]$ ]]; then
    export PROMPT_PROCEED=0
  else
    export PROMPT_PROCEED=1
  fi

  echo ""
}

get_package_manager() {
  local kernel
  kernel=$(uname -s)

  case $kernel in
    Darwin)
      # Get the current execution context
      local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

      # Ensure Homebrew exists
      source $SCRIPT_DIR/@macos/ensure_brew.zsh
      ensure_brew
      PACKAGE_MANAGER="brew"
      ;;
    Linux)
      if (( ${+commands[apt]} )); then
        PACKAGE_MANAGER="apt"
      elif (( ${+commands[yum]} )); then
        PACKAGE_MANAGER="yum"
      else
        logger "error" "Detected unsupported distribution: $(lsb_release -si)!"
        exit 1
      fi
      ;;
    *)
      logger "error" "Detected unsupported kernel: $kernel!"
      exit 1
      ;;
  esac
}
