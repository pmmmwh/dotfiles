# Use the text that has already been typed as the prefix for searching through commands
# (i.e. enables a more intelligent Up/Down behavior)
bindkey "\e[A" history-search-backward # ↑
bindkey "\e[B" history-search-forward  # ↓
bindkey "\e[1;3D" backward-word        # ⌥←
bindkey "\e[1;3C" forward-word         # ⌥→
bindkey "^[[1;9D" beginning-of-line    # ⌘←
bindkey "^[[1;9C" end-of-line          # ⌘→

# Enable the Starship theme
_evalcache starship init zsh

# Initialize tools (with lazyload if possible)
(( $+commands[atuin] )) && _evalcache atuin init zsh
(( $+commands[mise] )) && _evalcache mise activate zsh
(( $+commands[orbctl] )) && [[ -n $HOME/.orbstack/shell/init.zsh ]] && source $HOME/.orbstack/shell/init.zsh
(( $+commands[rustup-init] )) && [[ -n $HOME/.cargo/env ]] && source $HOME/.cargo/env

# Load library files
for libraryFile ($ZSH_CUSTOM/interactive/*.zsh); do
  source $libraryFile
done

# Initialise the auto-completion system to consume extra completions (for bash/zsh).
autoload -Uz bashcompinit
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  bashcompinit
	compinit
else
  bashcompinit -C
	compinit -C
fi

# Load completion files
typeset -U FPATH fpath
if [[ -n $BREW_LOCATION ]]; then
  fpath=(${BREW_LOCATION:h:h}/share/zsh/site-functions $fpath)
fi
fpath=(
  $ZSH_CUSTOM/completions
  $ZSH_CUSTOM/plugins/zsh-completions/src
  $fpath
)

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards)
[ -e $HOME/.ssh/config ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for frequently used apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Music Safari SystemUIServer Terminal wezterm-gui" killall
