# Use ~/.zshcustom as the ZSH_CUSTOM folder
export ZSH_CUSTOM=$HOME/.zshcustom

# Name the platform as `@`-prefixed directories do, for loading platform specific files
case $OSTYPE in
  darwin*) ZSH_PLATFORM=macos ;;
  linux*) ZSH_PLATFORM=linux ;;
  *) ZSH_PLATFORM=unknown ;;
esac

# Load evalcache plugin
source $ZSH_CUSTOM/plugins/evalcache/evalcache.plugin.zsh
