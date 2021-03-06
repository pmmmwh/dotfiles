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
  brew install goenv nvm pyenv rbenv

  # Setup Golang with the latest stable version (i.e. not beta/rc)
  GOLANG_VERSION=$(goenv install --list | sed "s/^  //" | grep "^[0-9]" | grep -v "beta\|rc" | tail -1)
  goenv install $GOLANG_VERSION
  goenv global $GOLANG_VERSION
  unset GOLANG_VERSION
  logger "success" "Successfully setup Golang."

  # Load `nvm`
  source "$(brew --prefix)/opt/nvm/nvm.sh"
  # Setup Node.js with the latest stable version
  nvm install stable
  logger "success" "Successfully setup Node.js."

  # Setup Python with the latest stable version (i.e. not dev/alpha/beta)
  PYTHON_VERSION=$(pyenv install --list | sed "s/^  //" | grep "^[0-9]" | grep -v "dev\|a\|b" | tail -1)
  pyenv install $PYTHON_VERSION
  pyenv global $PYTHON_VERSION
  unset PYTHON_VERSION
  logger "success" "Successfully setup Python."

  # Setup Ruby with the latest stable version (i.e. not dev/preview/rc)
  RUBY_VERSION=$(rbenv install --list-all | sed "s/^  //" | grep "^[0-9]" | grep -v "dev\|p\|preview\|rc" | tail -1)
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
  unset RUBY_VERSION
  logger "success" "Successfully setup Ruby."

  logger "info" "Bundling dependencies with Homebrew ..."
  # Initialise the `brew bundle` command
  brew tap homebrew/bundle

  # Selectively install dependencies based on personal computer or not
  prompt "Are you setting up a personal computer?"

  # Install all dependencies from `Brewfile`
  brew bundle --file=$SCRIPT_DIR/Brewfile --no-lock

  # Install all dependencies from `Brewfile.personal` if specified
  if (( $PROMPT_PROCEED == 0 )); then
    brew bundle --file=$SCRIPT_DIR/Brewfile.personal --no-lock
  fi

  # Install global tools
  logger "info" "Installing global tools ..."
  pip install pipx
  pipx install pipenv
  gem install bundler
  yarn global add serve

  logger "success" "Successfully setup Homebrew dependencies."
}
