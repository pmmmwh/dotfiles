#!/usr/bin/env zsh

ensure_env() {
  # Request elevated permissions
  elevate

  # Get the appropriate package manager to use for the current system;
  # the result will be stored in $PACKAGE_MANAGER.
  get_package_manager

  for package (curl git stow); do
    logger "info" "Checking for ${(C)package} installation ..."

    if (( ! ${+commands[$package]} )); then
      if $PACKAGE_MANAGER install $package; then
        rehash
        logger "success" "Successfully installed ${(C)package}."
      else
        logger "error" "Failed to install ${(C)package}!"
        exit 1
      fi
    fi
  done

  unset PACKAGE_MANAGER
}
