#!/usr/bin/env zsh

() {
  # Get the current execution context
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  # Source commons (e.g. logging)
  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh(N) $SCRIPT_DIR/../_lib/@macos/*.zsh(N)); do
    source $libraryFile
  done

  # Adopted from Mathias Bynens' dotfiles - originally licensed under MIT
  # ~/.macos - https://mths.be/macos

  # Request elevated permissions
  elevate

  # Close any open System Settings panes -
  # this is to prevent them from overriding settings we’re about to change
  osascript -e 'tell application "System Settings" to quit'

  logger "info" "Setting macOS defaults ..."

  ###############################################################################
  # General UI/UX                                                               #
  ###############################################################################

  # Set computer name, if possible (as done via System Settings -> Sharing)
  if (( ${+COMPUTER_NAME} )); then
    sudo scutil --set ComputerName $COMPUTER_NAME
    sudo scutil --set HostName $COMPUTER_NAME
    sudo scutil --set LocalHostName $COMPUTER_NAME
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
  fi

  # Show IP address, hostname, OS version etc.,
  # when clicking the clock in the login window
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  # Show battery percentage in menu bar
  defaults write $HOME/Library/Preferences/ByHost/com.apple.controlcenter.plist "BatteryShowPercentage" -bool "true"

  # Hide unwanted items in menu bar
  defaults write $HOME/Library/Preferences/ByHost/com.apple.controlcenter.plist "Display" -int 8
  defaults write $HOME/Library/Preferences/ByHost/com.apple.controlcenter.plist "NowPlaying" -int 8
  defaults write $HOME/Library/Preferences/ByHost/com.apple.controlcenter.plist "ScreenMirroring" -int 8
  defaults write $HOME/Library/Preferences/ByHost/com.apple.controlcenter.plist "Sound" -int 8

  ###############################################################################
  # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
  ###############################################################################

  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool "true"

  # Use scroll gesture with the Ctrl (^) modifier key to zoom
  sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool "true"
  sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

  # Follow the keyboard focus while zoomed in
  sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool "true"

  # Set language and text formats
  defaults write NSGlobalDomain AppleLanguages -array "en-GB" "zh-Hant-HK" "sv-SE"

  # Set the timezone and sync automatically from network
  # See `sudo systemsetup -listtimezones` for other values

  # Settings for Hong Kong
  # sudo systemsetup -settimezone "Asia/Hong_Kong" 2>/dev/null
  # sudo systemsetup -setnetworktimeserver "time.asia.apple.com" 2>/dev/null

  # Settings for Stockholm
  sudo systemsetup -settimezone "Europe/Stockholm" 2>/dev/null
  sudo systemsetup -setnetworktimeserver "time.euro.apple.com" 2>/dev/null
  sudo systemsetup -setusingnetworktime on

  ###############################################################################
  # Energy saving                                                               #
  ###############################################################################

  # Enable lid wakeup
  sudo pmset -a lidwake 1

  # Restart automatically on power loss
  sudo pmset -a autorestart 1

  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on 2>/dev/null

  # Sleep the display after 15 minutes
  sudo pmset -a displaysleep 15

  # Disable machine sleep while charging
  sudo pmset -c sleep 0

  # Set machine sleep to 30 minutes on battery
  sudo pmset -b sleep 30

  # Set standby delay to 24 hours if battery is above 50%,
  # and to 3 hours otherwise
  sudo pmset -a highstandbythreshold 50
  sudo pmset -a standbydelaylow 10800
  sudo pmset -a standbydelayhigh 86400

  # Never go into computer sleep mode
  sudo systemsetup -setcomputersleep Never 2>/dev/null

  # Hibernation mode
  # 0: Disable hibernation (speeds up entering sleep mode)
  # 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
  sudo pmset -a hibernatemode 3

  ###############################################################################
  # Screen                                                                      #
  ###############################################################################

  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "$HOME/Desktop"

  # Enable HiDPI display modes (requires restart)
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool "true"

  ###############################################################################
  # Finder                                                                      #
  ###############################################################################

  defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

  # Enable snap-to-grid for icons on the desktop and in other icon views
  local PREFERENCES="$HOME/Library/Preferences/com.apple.finder.plist"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"

  # Show the ~/Library folder
  xattr -d com.apple.FinderInfo ~/Library 2>/dev/null
  chflags nohidden ~/Library

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool "true" \
    OpenWith -bool "true" \
    Privileges -bool "true"

  ###############################################################################
  # Dock, Dashboard and Window Manager                                          #
  ###############################################################################

  # Reset Launchpad, but keep the desktop wallpaper intact
  find "${HOME}/Library/Application Support/Dock" -maxdepth 1 -name "*-*.db" -delete

  # Add Simulator to Launchpad
  sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"

  # Wipe all (default) app icons from the Dock
  defaults write com.apple.dock persistent-apps -array

  # Wipe all (default) folder icons from the Dock
  defaults write com.apple.dock persistent-others -array

  # Add frequently used apps and folders to the Dock
  local app folder
  for app (
    '/System/Applications/Music.app'
    '/Applications/Firefox.app'
    '/Applications/Mimestream.app'
    '/System/Applications/Calendar.app'
    '/Applications/Linear.app'
    '/Applications/Slack.app'
    '/Applications/Ghostty.app'
    '/System/Applications/System Settings.app'
  ); do
    add_app_to_dock $app
  done

  for folder ($HOME/Downloads); do
    add_folder_to_dock $folder -a 2
  done

  ###############################################################################
  # Mail                                                                        #
  ###############################################################################

  # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
  defaults write -app "Mail" NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

  # Display emails in threaded mode, sorted by date (oldest at the top)
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -bool "true"
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "SortedDescending" -bool "true"
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

  ###############################################################################
  # Terminal                                                                    #
  ###############################################################################

  # Only use UTF-8 in Terminal.app
  defaults write -app "Terminal" StringEncodings -array 4

  ###############################################################################
  # Photos                                                                      #
  ###############################################################################

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write -app "Image Capture" disableHotPlug -bool "true"

  ###############################################################################
  # Kill affected applications                                                  #
  ###############################################################################

  for app (
    "Activity Monitor"
    "App Store"
    "cfprefsd"
    "Disk Utility"
    "Dock"
    "Finder"
    "ghostty"
    "Image Capture"
    "Mail"
    "Photos"
    "SystemUIServer"
    "Terminal"
    "TextEdit"
    "Time Machine"
  ); do
    killall "$app" &>/dev/null
  done

  logger "success" "Successfully set macOS defaults. Note that some changes require a logout/restart to take effect."
}
