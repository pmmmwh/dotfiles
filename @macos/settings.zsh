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

  # Disable automatic termination of inactive apps
  # Commented out for now to cope with older devices
  # defaults write NSGlobalDomain NSDisableAutomaticTermination -bool "true"

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

  # Disable Notification Center and remove the menu bar icon
  # Commented out for Big Sur
  # launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

  ##############################################################################
  # Security                                                                   #
  ##############################################################################
  # Based on:
  # https://github.com/drduh/macOS-Security-and-Privacy-Guide
  # https://benchmarks.cisecurity.org/tools2/osx/CIS_Apple_OSX_10.12_Benchmark_v1.0.0.pdf

  # Enable firewall. Possible values:
  #   0 = off
  #   1 = on for specific sevices
  #   2 = on for essential services
  # sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

  # Enable stealth mode
  # Source: https://support.apple.com/kb/PH18642
  # sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

  # Enable firewall logging
  # sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1

  # Do not automatically allow signed software to receive incoming connections
  # sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool "false"

  # Log firewall events for 90 days
  # sudo perl -p -i -e 's/rotate=seq compress file_max=5M all_max=50M/rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"
  # sudo perl -p -i -e 's/appfirewall.log file_max=5M all_max=50M/appfirewall.log rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"

  # Reload the firewall
  # (uncomment if above is not commented out)
  # launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
  # sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
  # sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
  # launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist

  # Disable IR remote control
  # sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool "false"

  # Turn Bluetooth off completely
  # sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
  # sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
  # sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist

  # Disable wifi captive portal
  # sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool "false"

  # Disable remote apple events
  # sudo systemsetup -setremoteappleevents off

  # Disable remote login
  # sudo systemsetup -setremotelogin off

  # Disable wake-on modem
  # sudo systemsetup -setwakeonmodem off
  # sudo pmset -a ring 0

  # Disable wake-on LAN
  # sudo systemsetup -setwakeonnetworkaccess off
  # sudo pmset -a womp 0

  # Disable file-sharing via AFP or SMB
  # sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
  # sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist

  # Display login window as name and password
  # sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool "true"

  # Do not show password hints
  # sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

  # Disable guest account login
  # sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool "false"

  # Automatically lock the login keychain for inactivity after 6 hours
  # security set-keychain-settings -t 21600 -l ~/Library/Keychains/login.keychain

  # Destroy FileVault key when going into standby mode, forcing a re-auth.
  # Source: https://web.archive.org/web/20160114141929/http://training.apple.com/pdf/WP_FileVault2.pdf
  # sudo pmset destroyfvkeyonstandby 1

  # Enable secure virtual memory
  # sudo defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool "true"

  # Disable Bonjour multicast advertisements
  # sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool "true"

  # Disable the crash reporter
  # Commented out for now to cope with devices on beta software
  # defaults write com.apple.CrashReporter DialogType -string "none"

  # Disable diagnostic reports
  # Commented out for now to cope with devices on beta software
  # sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.SubmitDiagInfo.plist

  # Log authentication events for 90 days
  # sudo perl -p -i -e 's/rotate=seq file_max=5M all_max=20M/rotate=utc file_max=5M ttl=90/g' "/etc/asl/com.apple.authd"

  # Log installation events for a year
  # sudo perl -p -i -e 's/format=bsd/format=bsd mode=0640 rotate=utc compress file_max=5M ttl=365/g' "/etc/asl/com.apple.install"

  # Increase the retention time for system.log and secure.log
  # sudo perl -p -i -e 's/\/var\/log\/wtmp.*$/\/var\/log\/wtmp   \t\t\t640\ \ 31\    *\t\@hh24\ \J/g' "/etc/newsyslog.conf"

  # Keep a log of kernel events for 30 days
  # sudo perl -p -i -e 's|flags:lo,aa|flags:lo,aa,ad,fd,fm,-all,^-fa,^-fc,^-cl|g' /private/etc/security/audit_control
  # sudo perl -p -i -e 's|filesz:2M|filesz:10M|g' /private/etc/security/audit_control
  # sudo perl -p -i -e 's|expire-after:10M|expire-after: 30d |g' /private/etc/security/audit_control

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
  # Safari & WebKit                                                             #
  ###############################################################################

  # Disable auto-playing video
  # defaults write -app "Safari" WebKitMediaPlaybackAllowsInline -bool "false"
  # defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool "false"

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

  # Use the Dracula theme by default in Terminal.app
  osascript <<EOD
tell application "Terminal"

  local allOpenedWindows
  local initialOpenedWindows
  local windowID
  set themeName to "Dracula"

  (* Store the IDs of all the open terminal windows. *)
  set initialOpenedWindows to id of every window

  (* Open the custom theme so it gets added to the list of available terminal themes
     (note: this will open two additional terminal windows). *)
  do shell script "open '$SCRIPT_DIR/init/" & themeName & ".terminal'"

  (* Wait a little bit to ensure that the custom theme is added. *)
  delay 1

  (* Set the custom theme as the default terminal theme. *)
  set default settings to settings set themeName

  (* Get the IDs of all the currently opened terminal windows. *)
  set allOpenedWindows to id of every window

  repeat with windowID in allOpenedWindows

    (* Close the additional windows that were opened
       in order to add the custom theme to the list of terminal themes. *)
    if initialOpenedWindows does not contain windowID then
      close (every window whose id is windowID)

    (* Change the theme for the initial opened terminal windows
       and remove the need to close them
       in order for the custom theme to be applied. *)
    else
      set current settings of tabs of (every window whose id is windowID) to settings set themeName
    end if

  end repeat

end tell

EOD

  # Only use UTF-8 in Terminal.app
  defaults write -app "Terminal" StringEncodings -array 4

  ###############################################################################
  # Time Machine                                                                #
  ###############################################################################

  ###############################################################################
  # Activity Monitor                                                            #
  ###############################################################################

  ###############################################################################
  # TextEdit and Disk Utility                                                   #
  ###############################################################################

  ###############################################################################
  # Mac App Store                                                               #
  ###############################################################################

  ###############################################################################
  # Photos                                                                      #
  ###############################################################################

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write -app "Image Capture" disableHotPlug -bool "true"

  ###############################################################################
  # Google Chrome                                   #
  ###############################################################################

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
    "Google Chrome"
    "Image Capture"
    "Mail"
    "Photos"
    "Safari"
    "SystemUIServer"
    "Terminal"
    "TextEdit"
    "Time Machine"
  ); do
    killall "$app" &>/dev/null
  done

  logger "success" "Successfully set macOS defaults. Note that some changes require a logout/restart to take effect."
}
