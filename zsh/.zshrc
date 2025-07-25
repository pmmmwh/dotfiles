# Enable the Starship theme
_evalcache starship init zsh

# Load plugins
source $ZSH_CUSTOM/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-completions/zsh-completions.plugin.zsh

# Load library files
for libraryFile ($ZSH_CUSTOM/interactive/*.zsh); do
  source $libraryFile
done

# Initialise key bindings
bindkey "\e[A" atuin-up-search                                # ↑
bindkey "\eOA" atuin-up-search                                # ↑
bindkey "\e[1;3A" atuin-up-search                             # ⌥↑
bindkey "\e[1;3D" backward-word                               # ⌥←
bindkey "\e[1;3C" forward-word                                # ⌥→
bindkey "^[[1;9D" beginning-of-line                           # ⌘←
bindkey "^[[1;9C" end-of-line                                 # ⌘→
bindkey '^P' atuin-up-search                                  # ^P
bindkey '^R' atuin-search                                     # ^R
bindkey '^S' atuin-search                                     # ^S
bindkey "^I" menu-select                                      # ↹
bindkey -M menuselect "^I" menu-complete                      # ↹
bindkey "$terminfo[kcbt]" reverse-menu-select                 # ⇧↹
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete # ⇧↹

# Load completion files
typeset -U FPATH fpath
if [[ -n $BREW_LOCATION ]]; then
  fpath=(${BREW_LOCATION:h:h}/share/zsh/site-functions $fpath)
fi
fpath=($ZSH_CUSTOM/completions $fpath)

# Initialize tools (with lazyload if possible)
(( $+commands[atuin] )) && _evalcache atuin init zsh --disable-up-arrow --disable-ctrl-r
(( $+commands[mise] )) && _evalcache mise activate zsh
(( $+commands[orbctl] )) && [[ -n $HOME/.orbstack/shell/init.zsh ]] && source $HOME/.orbstack/shell/init.zsh
(( $+commands[rustup-init] )) && [[ -n $HOME/.cargo/env ]] && source $HOME/.cargo/env

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards)
[ -e $HOME/.ssh/config ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for frequently used apps
complete -o "nospace" -W "Contacts Calendar Dock Finder ghostty Mail Music Safari SystemUIServer Terminal" killall

# Add tab completion for Terraform
(( $+commands[terraform] )) && complete -o "nospace" -C "$commands[terraform]" terraform
