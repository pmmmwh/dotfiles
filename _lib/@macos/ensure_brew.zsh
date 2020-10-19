ensure_brew() {
  installed_xcode_cli_tools() {
    xcode-select --print-path &>/dev/null
  }

  # Check for Xcode CLI tools
  logger "info" "Checking for Xcode CLI tools ..."
  xcode-select --install 2>/dev/null

  until installed_xcode_cli_tools; do
    sleep 5
  done

  # Check for Homebrew, and install it if not found
  logger "info" "Checking for Homebrew installation ..."

  if (( ! ${+commands[brew]} )); then
    logger "warning" "Homebrew not found, downloading from source ..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    logger "success" "Successfully installed Homebrew."
  fi
}
