#!/usr/bin/env zsh

# Make VSCode the default editor for commands that support the $EDITOR variable
export EDITOR=code

# Enable persistent REPL history for `node`
export NODE_REPL_HISTORY=$HOME/.node_repl_history
# Allow 32³ entries (The default is 1000)
export NODE_REPL_HISTORY_SIZE=32768
# Use sloppy mode by default, matching the behaviour of web browsers
export NODE_REPL_MODE=sloppy

# Make Python use UTF-8 encoding for IO (stdin, stdout, and stderr)
export PYTHONIOENCODING="UTF-8"

# Use US English and UTF-8 encoding by default
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Avoid issues with `gpg` (installed via Homebrew)
# Ref: https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)
