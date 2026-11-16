# Use ~/.zshcustom as the ZSH_CUSTOM folder
export ZSH_CUSTOM=$HOME/.zshcustom

# Name the platform as `@`-prefixed directories do, for loading platform specific files
case $OSTYPE in
  darwin*) ZSH_PLATFORM=macos ;;
  linux*) ZSH_PLATFORM=linux ;;
  *) ZSH_PLATFORM=unknown ;;
esac

# Ensure global compinit is skipped (e.g. on Ubuntu), as zsh-autocomplete redoes it
skip_global_compinit=1

# Load evalcache plugin, caching in snake_case like other zsh paths (e.g. ~/.zsh_history)
export ZSH_EVALCACHE_DIR=$HOME/.zsh_evalcache
source $ZSH_CUSTOM/plugins/evalcache/evalcache.plugin.zsh
