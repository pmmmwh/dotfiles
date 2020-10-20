# Add `/usr/local/bin`, `~/bin` and `~/.local/bin` to $PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Setup GNU utilities
if (( ${+commands[brew]} )); then
  if [[ -n "${BREW_PREFIX:-$(brew --prefix)}/opt/*/libexec/gnubin(#qN)" ]]; then
    for gnuPath ("${BREW_PREFIX:-$(brew --prefix)}/opt/*/libexec/gnubin"); do
      export PATH="$PATH:$gnuPath"
    done

    unset gnuPath
  fi

  if [[ -n "${BREW_PREFIX:-$(brew --prefix)}/opt/*/libexec/gnuman(#qN)" ]]; then
    for gnuManPath ("${BREW_PREFIX:-$(brew --prefix)}/opt/*/libexec/gnuman"); do
      export MANPATH="$MANPATH:$gnuManPath"
    done

    unset gnuManPath
  fi
fi

# Setup usage of VSCode from command line
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Setup Android Studio development environment
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
