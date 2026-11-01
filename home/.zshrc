# Disable filename expansion for `=`
setopt noequals

# Enable case-insensitive globing (used in pathname expansion)
setopt nocaseglob

# Enable extended globing for qualifiers
setopt extendedglob

# Load universal library files, if in a non-login shell (i.e. .zprofile not sourced)
if [[ ! -o login ]]; then
  for libraryFile ($ZSH_CUSTOM/*.zsh(N)); do
    source $libraryFile
  done
fi

# Load completion files
typeset -U FPATH fpath
if [[ -n $HOMEBREW_PREFIX ]]; then
  fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
fi
fpath=($ZSH_CUSTOM/completions $fpath)

# Load plugins -
# only `zsh-completions` (fpath-only) is needed up front, the rest run after the first prompt
source $ZSH_CUSTOM/plugins/zsh-defer/zsh-defer.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-completions/zsh-completions.plugin.zsh
zsh-defer source $ZSH_CUSTOM/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Queue `compdef` calls for zsh-autocomplete, which does the only `compinit`;
# having it defined also stops mise's activation from running its own
typeset -ga _zshrc_compdef_queue=()
compdef() { _zshrc_compdef_queue+=("${(j: :)${(@q+)@}}") }

# Enable mise environment
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# Enable the Starship theme
_evalcache starship init zsh

# Load interactive library files
for libraryFile ($ZSH_CUSTOM/interactive/*.zsh(N)); do
  source $libraryFile
done

# Custom completions, after the queued `compdef` calls are handed to zsh-autocomplete
_zshrc_completions() {
  local queued
  for queued in $_zshrc_compdef_queue; do eval "compdef $queued"; done
  unset _zshrc_compdef_queue

  # Add tab completion for `defaults read|write NSGlobalDomain`
  complete -W "NSGlobalDomain" defaults

  # Add `killall` tab completion for frequently used apps
  complete -o "nospace" -W "Contacts Calendar Dock Finder ghostty Mail Music Safari SystemUIServer Terminal" killall

  # Add tab completion for Terraform
  (( $+commands[terraform] )) && complete -o "nospace" -C "$commands[terraform]" terraform
}
zsh-defer source $ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
zsh-defer _zshrc_completions

# Initialize atuin, before the key bindings that use its widgets
(( $+commands[atuin] )) && zsh-defer -c '_evalcache atuin init zsh --disable-up-arrow --disable-ctrl-r'

# Key bindings use widgets from the deferred plugins above
_zshrc_key_bindings() {
  bindkey "\e[A" atuin-up-search                                # ↑
  bindkey "\eOA" atuin-up-search                                # ↑
  bindkey "\e[1;3A" atuin-up-search                             # ⌥↑
  bindkey "\e[1;3D" backward-word                               # ⌥←
  bindkey "\e[1;3C" forward-word                                # ⌥→
  bindkey "^[[1;9D" beginning-of-line                           # ⌘←
  bindkey "^[[1;9C" end-of-line                                 # ⌘→
  bindkey '^P' atuin-up-search                                  # ^P
  bindkey "\ep" atuin-up-search                                 # ⌥P
  bindkey '^R' atuin-search                                     # ^R
  bindkey '^S' atuin-search                                     # ^S
  bindkey "^I" menu-select                                      # ↹
  bindkey -M menuselect "^I" menu-complete                      # ↹
  bindkey "$terminfo[kcbt]" reverse-menu-select                 # ⇧↹
  bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete # ⇧↹
}
zsh-defer _zshrc_key_bindings
