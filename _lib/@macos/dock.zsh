#!/usr/bin/env zsh

# Adds an application to the macOS Dock
add_app_to_dock() {
  local app=$1

  if open -Ra $app; then
    defaults write com.apple.dock persistent-apps -array-add \
"<dict>
    <key>tile-data</key>
    <dict>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>$app</string>
            <key>_CFURLStringType</key>
            <integer>0</integer>
        </dict>
    </dict>
</dict>"

  logger "success" "$app has been added to the Dock."
  else
    logger "error" "Application $app not found!"
  fi
}

# Adds a folder to the macOS Dock
# Flags:
# -a or --arrangement
#   1 -> Name
#   2 -> Date Added
#   3 -> Date Modified
#   4 -> Date Created
#   5 -> Kind
# -d or --displayAs
#   0 -> Stack
#   1 -> Folder
# -v or --showAs
#   0 -> Automatic
#   1 -> Fan
#   2 -> Grid
#   3 -> List
add_folder_to_dock() {
  local folder=$1

  local arrangement="1"
  local displayAs="0"
  local showAs="0"
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -a|--arrangement)
        if [[ $2 =~ ^[1-5]$ ]]; then
            arrangement=$2
        fi
        ;;
      -d|--displayAs)
        if [[ $2 =~ ^[0-1]$ ]]; then
            displayAs=$2
        fi
        ;;
      -v|--showAs)
        if [[ $2 =~ ^[0-3]$ ]]; then
            showAs=$2
        fi
        ;;
    esac
    shift
  done

  if [ -d $folder ]; then
    defaults write com.apple.dock persistent-others -array-add \
"<dict>
    <key>tile-data</key>
    <dict>
        <key>arrangement</key>
        <integer>$arrangement</integer>
        <key>displayas</key>
        <integer>$displayAs</integer>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>file://$folder</string>
            <key>_CFURLStringType</key>
            <integer>15</integer>
        </dict>
        <key>file-type</key>
        <integer>2</integer>
        <key>showas</key>
        <integer>$showAs</integer>
    </dict>
    <key>tile-type</key>
    <string>directory-tile</string>
</dict>"

  logger "success" "$folder has been added to the Dock."
  else
    logger "error" "Folder $folder not found!"
  fi
}
