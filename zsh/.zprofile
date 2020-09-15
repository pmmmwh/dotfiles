# Disable filename expansion for `=`
setopt -s noequals

# Enable case-insensitive globbing (used in pathname expansion)
setopt -s nocaseglob

# Add tab completion for `pipx`
(( ${+commands[pipx]} )) && eval "$(register-python-argcomplete pipx)"

# Add tab completion for SSH hostnames based on ~/.ssh/config (ignoring wildcards)
[ -e $HOME/.ssh/config ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for frequently used apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Music Safari iTerm SystemUIServer Terminal" killall
