# Load library files
for libraryFile ($ZSH_CUSTOM/*.zsh(N) $ZSH_CUSTOM/@$ZSH_PLATFORM/*.zsh(N)); do
  source $libraryFile
done

# Enable mise shims -
# cover non-interactive callers that never reach .zshrc
(( $+commands[mise] )) && _evalcache mise activate zsh --shims
