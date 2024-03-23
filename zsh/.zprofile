# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.pre.zsh"

# Disable filename expansion for `=`
setopt noequals

# Enable case-insensitive globing (used in pathname expansion)
setopt nocaseglob

# Enable extended globing for qualifiers
setopt extendedglob

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.post.zsh"
