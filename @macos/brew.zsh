#!/usr/bin/env zsh

() {
  # Get the current execution context
  SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  # Source commons (e.g. logging)
  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh $SCRIPT_DIR/../_lib/@macos/*.zsh); do
    source $libraryFile
  done

  # Request elevated permissions
  elevate
  ensure_brew

  # Ensure latest version of Homebrew is used, and upgrade any already-installed formulae
  logger "info" "Updating Homebrew and formulae ..."
  brew upgrade

  # Preinstall version managers for Golang, Node.js, Python and Ruby
  # This have to be done because dependencies down the line in `Brewfile` might depend on them.
  # Since Homebrew's `ignore-dependencies` flag is not encouraged,
  # we will ensure the environment is properly setup before proceeding with `homebrew bundle`.
  logger "info" "Setting up the installation environment ..."
  brew install mise

  # Setup Node.js, Python, Golang and Ruby with the specified versions
  mise trust $HOME/.config/mise/config.toml
  mise install
  logger "success" "Successfully setup tooling."

  logger "info" "Bundling dependencies with Homebrew ..."

  # Selectively install dependencies based on personal computer or not
  prompt "Are you setting up a personal computer?"

  # Install all dependencies from `Brewfile`
  brew bundle --file=$SCRIPT_DIR/Brewfile

  # Install all dependencies from `Brewfile.personal` if specified
  if (( $PROMPT_PROCEED == 0 )); then
    brew bundle --file=$SCRIPT_DIR/Brewfile.personal
  fi

  # Install global tools
  logger "info" "Installing global tools ..."

  logger "success" "Successfully setup Homebrew dependencies."
}
