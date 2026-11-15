#!/usr/bin/env -S zsh -f

() {
  # Get the current execution context
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  # Source commons (e.g. logging)
  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh(N) $SCRIPT_DIR/../_lib/@macos/*.zsh(N)); do
    source $libraryFile
  done

  if [[ $OSTYPE != darwin* ]]; then
    logger "error" "These settings only apply to macOS."
    exit 1
  fi

  # Adopted from Mathias Bynens' dotfiles - originally licensed under MIT
  # ~/.macos - https://mths.be/macos

  # Close any open System Settings panes -
  # this is to prevent them from overriding settings we’re about to change
  osascript -e 'tell application "System Settings" to quit'

  logger "info" "Setting macOS defaults ..."

  # System-wide settings run in one root process, so sudo only asks once
  logger "info" "Requesting administrator credentials for system settings ..."
  sudo /bin/zsh -f "$SCRIPT_DIR/settings-system.zsh" "${COMPUTER_NAME:-}" "$HOME" || exit 1

  ###############################################################################
  # Finder                                                                      #
  ###############################################################################

  defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

  # Show the ~/Library folder
  xattr -d com.apple.FinderInfo ~/Library 2>/dev/null
  chflags nohidden ~/Library

  ###############################################################################
  # Dock, Dashboard and Window Manager                                          #
  ###############################################################################

  # Wipe all (default) folder icons from the Dock
  defaults write com.apple.dock persistent-others -array

  # Add frequently used folders to the Dock
  local folder
  for folder ($HOME/Downloads); do
    add_folder_to_dock $folder -a 2
  done

  ###############################################################################
  # Kill affected applications                                                  #
  ###############################################################################

  killall Dock Finder SystemUIServer &>/dev/null

  logger "success" "Successfully set macOS defaults. Note that some changes require a logout/restart to take effect."
}
