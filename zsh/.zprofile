# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zprofile.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.pre.zsh"
# Disable filename expansion for `=`
setopt noequals

# Enable case-insensitive globing (used in pathname expansion)
setopt nocaseglob

# Enable extended globing for qualifiers
setopt extendedglob

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zprofile.post.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.post.zsh"
