ensure_brew() {
  # Check for Xcode CLI tools
  logger "info" "Checking for Xcode CLI tools ..."
  sudo xcode-select --install 2>/dev/null

  # Check for Homebrew, and install it if not found
  logger "info" "Checking for Homebrew installation ..."

  if (( ! ${+commands[brew]} )); then
    logger "warning" "Homebrew not found, downloading from source ..."

    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    logger "success" "Successfully installed Homebrew."
  fi
}
