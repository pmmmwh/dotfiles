#!/usr/bin/env zsh

# PATHS

# Setup OrbStack
(( $+commands[orbctl] )) && [[ -r $HOME/.orbstack/shell/init.zsh ]] && source $HOME/.orbstack/shell/init.zsh

# Setup usage of Ghostty from command line
if [[ -d "/Applications/Ghostty.app/Contents/MacOS" ]]; then
  path+="/Applications/Ghostty.app/Contents/MacOS"
fi

# Setup Android Studio development environment, if the SDK is installed
if [[ -d $HOME/Library/Android/sdk ]]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  path+=(
    $ANDROID_HOME/emulator
    $ANDROID_HOME/tools
    $ANDROID_HOME/tools/bin
    $ANDROID_HOME/platform-tools
  )
fi
