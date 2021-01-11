#!/usr/bin/env zsh

() {
  # Get the current execution context
  SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  # Source commons (e.g. logging)
  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh $SCRIPT_DIR/../_lib/@macos/*.zsh); do
    source $libraryFile
  done

  # Adopted from Mathias Bynens' dotfiles - originally licensed under MIT
  # ~/.macos - https://mths.be/macos

  # Request elevated permissions
  elevate

  # Close any open System Preferences panes -
  # this is to prevent them from overriding settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  logger "info" "Setting macOS defaults ..."

  ###############################################################################
  # General UI/UX                                                               #
  ###############################################################################

  # Set computer name, if possible (as done via System Preferences -> Sharing)
  if (( ${+COMPUTER_NAME} )); then
    sudo scutil --set ComputerName $COMPUTER_NAME
    sudo scutil --set HostName $COMPUTER_NAME
    sudo scutil --set LocalHostName $COMPUTER_NAME
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
  fi

  # Set sidebar icon size to medium
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  # Show scrollbars depending on the context
  # Possible values: `WhenScrolling`, `Automatic` and `Always`
  defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

  # Increase the window resize speed for Cocoa applications
  # This will make them open quicker
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # Double-click to maximize windows
  defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

  # Use dark mode by default
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

  # Use expanded save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Use expanded print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Automatically quit printer apps once the print jobs complete
  defaults write org.cups.PrintingPrefs "Quit When Finished" -bool true

  # Display ASCII control characters using caret notation in standard text views
  defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

  # Enable window-saving on quit system-wide
  defaults write -app "System Preferences" NSQuitAlwaysKeepsWindows -bool true

  # Disable window-saving on quit for QuickTime and Preview
  defaults write -app "QuickTime Player" NSQuitAlwaysKeepsWindows -bool false
  defaults write -app "Preview" NSQuitAlwaysKeepsWindows -bool false

  # Auto-play videos when opened with QuickTime Player
  defaults write -app "QuickTime Player" MGPlayMovieOnOpen -bool true

  # Disable automatic termination of inactive apps
  # Commented out for now to cope with older devices
  # defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

  # Set Help Viewer windows to non-floating mode
  defaults write com.apple.helpviewer DevMode -bool true

  # Show IP address, hostname, OS version etc.,
  # when clicking the clock in the login window
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  # Show Day of the week and 24-hour formatted clock in menu bar
  defaults write com.apple.menuextra.clock "DateFormat" -string "EEE HH:mm:ss"

  # Disable Notification Center and remove the menu bar icon
  # Commented out for Big Sur
  # launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

  # Disable automatic capitalization as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable automatic period substitution as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Enable spellchecker auto language identification
  defaults write NSGlobalDomain NSSpellCheckerAutomaticallyIdentifiesLanguages -bool true

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
  # sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false

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
  # sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false

  # Turn Bluetooth off completely
  # sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
  # sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
  # sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist

  # Disable wifi captive portal
  # sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

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
  # sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

  # Do not show password hints
  # sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

  # Disable guest account login
  # sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

  # Automatically lock the login keychain for inactivity after 6 hours
  # security set-keychain-settings -t 21600 -l ~/Library/Keychains/login.keychain

  # Destroy FileVault key when going into standby mode, forcing a re-auth.
  # Source: https://web.archive.org/web/20160114141929/http://training.apple.com/pdf/WP_FileVault2.pdf
  # sudo pmset destroyfvkeyonstandby 1

  # Enable secure virtual memory
  # sudo defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool true

  # Disable Bonjour multicast advertisements
  # sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

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

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Disable disk image verification
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

  ###############################################################################
  # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
  ###############################################################################

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Trackpad: enable tap to right-click
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  # Trackpad: enable force-click
  defaults write com.apple.trackpad.forceClick -bool true

  # Improve sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Use scroll gesture with the Ctrl (^) modifier key to zoom
  sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  # Follow the keyboard focus while zoomed in
  sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  # Enable press-and-hold - this is useful for typing "accents"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

  # Set language and text formats
  defaults write NSGlobalDomain AppleLanguages -array "en-GB" "zh-Hant-HK" "sv-SE"
  defaults write NSGlobalDomain AppleLocale -string "en_SE"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
  defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
  defaults write NSGlobalDomain AppleMetricUnits -bool true

  # Set the timezone and sync automatically from network
  # See `sudo systemsetup -listtimezones` for other values

  # Settings for Hong Kong
  # sudo systemsetup -settimezone "Asia/Hong_Kong" >/dev/null
  # sudo systemsetup -setnetworktimeserver "time.asia.apple.com"

  # Settings for Stockholm
  sudo systemsetup -settimezone "Europe/Stockholm" >/dev/null
  sudo systemsetup -setnetworktimeserver "time.euro.apple.com"
  sudo systemsetup -setusingnetworktime on

  ###############################################################################
  # Energy saving                                                               #
  ###############################################################################

  # Enable lid wakeup
  sudo pmset -a lidwake 1

  # Restart automatically on power loss
  sudo pmset -a autorestart 1

  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on

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
  sudo systemsetup -setcomputersleep Never >/dev/null

  # Hibernation mode
  # 0: Disable hibernation (speeds up entering sleep mode)
  # 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
  sudo pmset -a hibernatemode 3

  ###############################################################################
  # Screen                                                                      #
  ###############################################################################

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "$HOME/Desktop"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # Enable font anti-aliasing rendering when font-sizes are smaller than 4px
  defaults write NSGlobalDomain AppleAntiAliasingThreshold -int 4

  # Enable subpixel font rendering on non-Apple LCDs
  # Ref: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
  defaults write NSGlobalDomain AppleFontSmoothing -int 1

  # Disable Font Smoothing Disabler in macOS Mojave
  # Ref: https://ahmadawais.com/fix-macos-mojave-font-rendering-issue/
  defaults write -g CGFontRenderingFontSmoothingDisabled -bool false

  # Enable HiDPI display modes (requires restart)
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

  ###############################################################################
  # Finder                                                                      #
  ###############################################################################

  # Set $HOME as the default location for new Finder windows
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Enable spring loading for directories
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  # Use 0.5s spring loading delay for directories
  defaults write NSGlobalDomain com.apple.springing.delay -float 0.5

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Automatically open a new Finder window when a volume is mounted
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Enable snap-to-grid for icons on the desktop and in other icon views
  PREFERENCES="$HOME/Library/Preferences/com.apple.finder.plist"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" "$PREFERENCES"
  unset PREFERENCES

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `Icnv`, `Clmv`, `Glyv`
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Show the ~/Library folder
  xattr -d com.apple.FinderInfo ~/Library 2>/dev/null
  chflags nohidden ~/Library

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

  ###############################################################################
  # Dock and Dashboard                                                          #
  ###############################################################################

  # Move the dock on the left
  defaults write com.apple.dock orientation -string "left"

  # Set the icon size of Dock items to 32 pixels
  defaults write com.apple.dock tilesize -int 32

  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"

  # Minimize windows into their application’s icon
  defaults write com.apple.dock minimize-to-application -bool true

  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Disable Dashboard
  defaults write com.apple.dashboard dashboard-enabled-state -int 1

  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Magnify the dock on hover
  defaults write com.apple.dock magnification -bool true

  # Set the magnified icon size of Dock items to 48 pixels
  defaults write com.apple.dock largesize -int 48

  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Reset Launchpad, but keep the desktop wallpaper intact
  find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

  # Add Simulator to Launchpad
  sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"

  # Wipe all (default) app icons from the Dock
  defaults write com.apple.dock persistent-apps -array

  # Wipe all (default) folder icons from the Dock
  defaults write com.apple.dock persistent-others -array

  # Add frequently used apps and folders to the Dock
  for app (
    '/System/Applications/Launchpad.app'
    '/System/Applications/Music.app'
    '/Applications/Firefox.app'
    '/Applications/Fantastical.app'
    '/Applications/Slack.app'
    '/Applications/Notion.app'
    '/Applications/Superhuman.app'
    '/Applications/iTerm.app'
    '/System/Applications/System Preferences.app'
  ); do
    add_app_to_dock $app
  done
  unset app

  for folder ($HOME/Downloads); do
    add_folder_to_dock $folder -a 2
  done
  unset folder


  ###############################################################################
  # Safari & WebKit                                                             #
  ###############################################################################

  # Privacy: don’t send search queries to Apple
  defaults write -app "Safari" UniversalSearchEnabled -bool false
  defaults write -app "Safari" SuppressSearchSuggestions -bool true

  # Press Tab to highlight each item on a web page
  defaults write -app "Safari" WebKitTabToLinksPreferenceKey -bool true
  defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write -app "Safari" ShowFullURLInSmartSearchField -bool true

  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write -app "Safari" AutoOpenSafeDownloads -bool false

  # Allow hitting the Backspace key to go to the previous page in history
  defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

  # Hide Safari’s bookmarks bar by default
  defaults write -app "Safari" ShowFavoritesBar-v2 -bool false

  # Hide Safari’s sidebar in Top Sites
  defaults write -app "Safari" ShowSidebarInTopSites -bool false

  # Disable Safari’s thumbnail cache for History and Top Sites
  defaults write -app "Safari" DebugSnapshotsUpdatePolicy -int 2

  # Enable Safari’s debug menu
  defaults write -app "Safari" IncludeInternalDebugMenu -bool true

  # Make Safari’s search banners default to Contains instead of Starts With
  defaults write -app "Safari" FindOnPageMatchesWordStartsOnly -bool false

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write -app "Safari" IncludeDevelopMenu -bool true
  defaults write -app "Safari" WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Enable continuous spellchecking
  defaults write -app "Safari" WebContinuousSpellCheckingEnabled -bool true

  # Warn about fraudulent websites
  defaults write -app "Safari" WarnAboutFraudulentWebsites -bool true

  # Block pop-up windows
  defaults write -app "Safari" WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

  # Disable auto-playing video
  # defaults write -app "Safari" WebKitMediaPlaybackAllowsInline -bool false
  # defaults write -app "Safari" com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

  # Enable “Do Not Track”
  defaults write -app "Safari" SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write -app "Safari" InstallExtensionUpdatesAutomatically -bool true

  ###############################################################################
  # Mail                                                                        #
  ###############################################################################

  # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
  defaults write -app "Mail" NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

  # Display emails in threaded mode, sorted by date (oldest at the top)
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -bool true
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "SortedDescending" -bool true
  defaults write -app "Mail" DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

  # Disable inline attachments (just show the icons)
  defaults write -app "Mail" DisableInlineAttachmentViewing -bool true

  ###############################################################################
  # Terminal & iTerm 2                                                          #
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

  # Enable Secure Keyboard Entry in Terminal.app
  # See: https://security.stackexchange.com/a/47786/8918
  defaults write -app "Terminal" SecureKeyboardEntry -bool true

  # Generate a new profile for iTerm
  PREFERENCES="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  PROFILE_GUID=$(uuidgen)
  /usr/libexec/PlistBuddy -c "Copy ':New Bookmarks:0' ':New Bookmarks:1'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Guid' '$PROFILE_GUID'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Description' 'Dracula'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Description' 'Dracula'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Name' 'Dracula'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:ASCII Ligatures' bool true" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:Draw Powerline Glyphs' bool true" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:Initial Text' string ''" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:Minimum Contrast' integer 0" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Normal Font' 'MesloLGSNer-Regular 12'" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:Only The Default BG Color Uses Transparency' bool true" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Option Key Sends' 2" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:1:Right Option Key Sends' 2" "$PREFERENCES"
  /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:1:Show Mark Indicators' bool false" "$PREFERENCES"

  # Set the new profile as default
  defaults write -app "iTerm" "Default Bookmark Guid" $PROFILE_GUID
  unset PREFERENCES
  unset PROFILE_GUID

  # Don’t display the annoying prompt when quitting iTerm
  defaults write -app "iTerm" PromptOnQuit -bool false

  # Don't snap to grid when resizing iTerm (conflicts with window managers)
  defaults write -app "iTerm" DisableWindowSizeSnap -bool true

  # Send arrow keys with scroll wheel in interactive CLIs
  defaults write -app "iTerm" AlternateMouseScroll -bool true

  # Automatically check for iTerm updates
  defaults write -app "iTerm" SUEnableAutomaticChecks -bool true

  # Disable tip of the day
  defaults write -app "iTerm" NoSyncTipsDisabled -bool true

  # Install the Dracula colors for iTerm
  open "$SCRIPT_DIR/init/Dracula.itermcolors"

  ###############################################################################
  # Time Machine                                                                #
  ###############################################################################

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  ###############################################################################
  # Activity Monitor                                                            #
  ###############################################################################

  # Show the main window when launching Activity Monitor
  defaults write -app "Activity Monitor" OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write -app "Activity Monitor" IconType -int 5

  # Show all processes in Activity Monitor
  defaults write -app "Activity Monitor" ShowCategory -int 100

  # Sort Activity Monitor results by CPU usage
  defaults write -app "Activity Monitor" SortColumn -string "CPUUsage"
  defaults write -app "Activity Monitor" SortDirection -int 0

  ###############################################################################
  # TextEdit and Disk Utility                                                   #
  ###############################################################################

  # Use plain text mode for new TextEdit documents
  defaults write -app "TextEdit" RichText -int 0

  # Open and save files as UTF-8 in TextEdit
  defaults write -app "TextEdit" PlainTextEncoding -int 4
  defaults write -app "TextEdit" PlainTextEncodingForWrite -int 4

  # Enable the debug menu in Disk Utility
  defaults write -app "Disk Utility" DUDebugMenuEnabled -bool true
  defaults write -app "Disk Utility" advanced-image-options -bool true

  ###############################################################################
  # Mac App Store                                                               #
  ###############################################################################

  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  # Automatically download apps purchased on other Macs
  defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true

  # Allow the App Store to reboot machine on macOS updates
  defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

  ###############################################################################
  # Photos                                                                      #
  ###############################################################################

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write -app "Image Capture" disableHotPlug -bool true

  ###############################################################################
  # Google Chrome                                   #
  ###############################################################################

  # Use the system-native print preview dialog
  defaults write -app "Google Chrome" DisablePrintPreview -bool true

  # Expand the print dialog by default
  defaults write -app "Google Chrome" PMPrintingExpandedStateForPrint2 -bool true

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
    "Google Chrome"
    "Image Capture"
    "iTerm2"
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
