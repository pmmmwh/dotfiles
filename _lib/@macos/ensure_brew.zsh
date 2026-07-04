ensure_brew() {
  installed_xcode_cli_tools() {
    xcode-select --print-path &>/dev/null
  }

  # Check for Xcode CLI tools, installing them if missing
  logger "info" "Checking for Xcode CLI tools ..."
  if ! installed_xcode_cli_tools; then
    xcode-select --install 2>/dev/null

    # Bound the wait so a dismissed installer dialog can't hang setup forever
    local waited=0
    until installed_xcode_cli_tools; do
      if (( waited >= 600 )); then
        logger "error" "Timed out waiting for Xcode CLI tools installation!"
        exit 1
      fi
      sleep 5
      (( waited += 5 ))
    done
  fi

  # Check for Homebrew, and install it if not found
  logger "info" "Checking for Homebrew installation ..."

  if (( ! ${+commands[brew]} )); then
    logger "warning" "Homebrew not found, downloading from source ..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    if [[ $(/usr/bin/uname -m) == "arm64" ]]; then
      eval $(/opt/homebrew/bin/brew shellenv)
      export PATH
    else
      eval $(/usr/local/bin/brew shellenv)
    fi

    # Initialise paths for Homebrew binaries
    typeset -U PATH path
    path=($(brew --prefix)/bin $path)

    logger "success" "Successfully installed Homebrew."
  fi
}
