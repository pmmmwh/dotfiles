#!/usr/bin/env -S zsh -f

# System-wide macOS settings, which need root; per-user preferences live in conf.d/macos.toml.
# Adopted from Mathias Bynens' dotfiles - originally licensed under MIT (https://mths.be/macos)
# Usage: sudo settings.zsh [computer-name] [user-home] [nextdns-profile], as the macos-settings task runs it

() {
  # Get the current execution context
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)
  local COMPUTER_NAME=${1:-}
  local USER_HOME=${2:-}
  local NEXTDNS_PROFILE=${3:-}

  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh(N)); do
    source $libraryFile
  done

  if [[ $OSTYPE != darwin* ]]; then
    logger "error" "These settings only apply to macOS."
    exit 1
  fi

  if (( EUID != 0 )); then
    logger "error" "This script must be run as root."
    exit 1
  fi

  ###############################################################################
  # General UI/UX                                                               #
  ###############################################################################

  # Set computer name, if provided (as done via System Settings -> Sharing)
  if [[ -n $COMPUTER_NAME ]]; then
    # LocalHostName only allows letters, digits and hyphens
    local localHostName=${${COMPUTER_NAME// /-}//[^A-Za-z0-9-]/}
    scutil --set ComputerName $COMPUTER_NAME
    scutil --set HostName $localHostName
    scutil --set LocalHostName $localHostName
    defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $localHostName
  fi

  # Show IP address, hostname, OS version etc.,
  # when clicking the clock in the login window
  defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  ###############################################################################
  # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
  ###############################################################################

  # Use scroll gesture with the Ctrl (^) modifier key to zoom
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool "true"
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

  # Follow the keyboard focus while zoomed in
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool "true"

  # Set the timezone and sync automatically from network
  # See `systemsetup -listtimezones` for other values

  # Settings for Hong Kong
  # systemsetup -settimezone "Asia/Hong_Kong" 2>/dev/null
  # systemsetup -setnetworktimeserver "time.asia.apple.com" 2>/dev/null

  # Settings for Stockholm
  systemsetup -settimezone "Europe/Stockholm" 2>/dev/null
  systemsetup -setnetworktimeserver "time.euro.apple.com" 2>/dev/null
  systemsetup -setusingnetworktime on

  ###############################################################################
  # Energy saving                                                               #
  ###############################################################################

  # Enable lid wakeup
  pmset -a lidwake 1

  # Restart automatically on power loss
  pmset -a autorestart 1

  # Restart automatically if the computer freezes
  systemsetup -setrestartfreeze on 2>/dev/null

  # Sleep the display after 15 minutes
  pmset -a displaysleep 15

  # Disable machine sleep while charging
  pmset -c sleep 0

  # Set machine sleep to 30 minutes on battery
  pmset -b sleep 30

  # Set standby delay to 24 hours if battery is above 50%,
  # and to 3 hours otherwise
  pmset -a highstandbythreshold 50
  pmset -a standbydelaylow 10800
  pmset -a standbydelayhigh 86400

  # Never go into computer sleep mode
  systemsetup -setcomputersleep Never 2>/dev/null

  # Hibernation mode
  # 0: Disable hibernation (speeds up entering sleep mode)
  # 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
  pmset -a hibernatemode 3

  ###############################################################################
  # Screen                                                                      #
  ###############################################################################

  # Enable HiDPI display modes (requires restart)
  defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool "true"

  ###############################################################################
  # Network                                                                     #
  ###############################################################################

  # Resolve DNS over HTTPS with NextDNS for the whole system, if a profile is provided
  # Installing again replaces the service, keeping any other options in /etc/nextdns.conf
  if [[ -n $NEXTDNS_PROFILE ]]; then
    # sudo does not keep Homebrew on PATH
    local nextdns=/opt/homebrew/bin/nextdns
    if [[ -x $nextdns ]]; then
      $nextdns install \
        -profile $NEXTDNS_PROFILE \
        -auto-activate \
        -cache-size 10MB \
        -max-ttl 5s \
        -report-client-info
    else
      logger "warning" "NextDNS is not installed, DNS over HTTPS is not set up."
    fi
  fi

  ###############################################################################
  # Spotlight                                                                   #
  ###############################################################################

  # Keep repos out of Spotlight (as done via System Settings -> Spotlight -> Search Privacy)
  # Raycast finds files by name with its own index, and only its Content Search needs Spotlight
  local spotlightConfig=/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist
  local spotlightExclusion=$USER_HOME/Developer
  if [[ -n $USER_HOME && -d $spotlightExclusion && -f $spotlightConfig ]]; then
    local plistBuddy=/usr/libexec/PlistBuddy index=0 excluded=false entry
    if ! $plistBuddy -c "Print :Exclusions" $spotlightConfig &>/dev/null; then
      $plistBuddy -c "Add :Exclusions array" $spotlightConfig
    fi
    while entry=$($plistBuddy -c "Print :Exclusions:$index" $spotlightConfig 2>/dev/null); do
      [[ $entry == "$spotlightExclusion" ]] && excluded=true
      (( index++ ))
    done
    if [[ $excluded == false ]]; then
      $plistBuddy -c "Add :Exclusions:$index string $spotlightExclusion" $spotlightConfig
      # Spotlight reads its configuration on start, and launchd restarts it
      killall mds &>/dev/null
    fi
  fi

  ###############################################################################
  # Applications                                                                #
  ###############################################################################

  # Link Xcode's device app into /Applications, only when provided:
  # Device Hub from Xcode 27 (which replaced Simulator), or Simulator before that.
  local deviceApp
  for deviceApp (
    "/Applications/Xcode.app/Contents/Applications/DeviceHub.app"
    "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
  ); do
    if [[ -d $deviceApp ]]; then
      ln -sfn $deviceApp "/Applications/${deviceApp:t}"
      break
    fi
  done
  # A Simulator link left behind by an older Xcode now points nowhere
  if [[ -L /Applications/Simulator.app && ! -e /Applications/Simulator.app ]]; then
    rm /Applications/Simulator.app
  fi
}
