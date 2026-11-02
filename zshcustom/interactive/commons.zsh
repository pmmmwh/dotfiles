#!/usr/bin/env zsh

# ALIASES

# Run claude with personal config
alias claude-personal="CLAUDE_CONFIG_DIR=~/.claude.personal claude"

# Show all ports that are currently listning by a process
alias listeningports="sudo lsof -iTCP -sTCP:LISTEN -nP"

# An intuitive map function
# Usage (to list all directories that contain a certain file):
# `find . -name .gitattributes | map dirname`
alias map="xargs -n1"

# Prints all PATH entries, each on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec ${SHELL} -l'

# Get current week (number)
alias week="date +%V"

# Alias 7-zip to `7z`
(( ${+commands[7z]} )) || alias 7z="7zz"

# If available, use `diff` from Git instead of default
if (( ${+commands[git]} )); then
  alias diff="git diff --no-index --color-words"
fi

# FUNCTIONS

# Create a data URL from a file
dataurl() {
  local mimeType
  mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="$mimeType;charset=utf-8"
  fi

  echo "data:$mimeType;base64,$(openssl base64 -in "$1" | tr -d "\n")"
}

# Lookup a DNS using `dig` and display the most useful info
digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# Determine the (total) size of a directory or a file
fs() {
  local arg
  if du -b /dev/null >/dev/null 2>&1; then
    # GNU `du`
    arg=-bsh
  else
    # BSD `du`
    arg=-sh
  fi

  if [[ -n "$*" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

# Compare original and gzipped file sizes
gz() {
  local origSize
  local gzipSize
  local ratio

  origSize=$(wc -c <"$1")
  gzipSize=$(gzip -c "$1" | wc -c)
  ratio=$(echo "$gzipSize * 100 / $origSize" | bc -l)

  printf "Original: %d bytes\n" "$origSize"
  printf "Gzipped : %d bytes (%2.2f%%)\n" "$gzipSize" "$ratio"
}

# Create a new directory and move inside it
mkd() {
  mkdir -p "$@" && cd "$_" || return
}

# Create a .tar.gz archive
# This will use `zopfli`, `pigz` or `gzip` for compression depending on the situation
targz() {
  local tmpFile="${*%/}.tar"
  tar -cvf "$tmpFile" --exclude=".DS_Store" "$@" || return 1

  size=$(
    # BSD `stat`
    stat -f"%z" "$tmpFile" 2>/dev/null
    # GNU `stat`
    stat -c"%s" "$tmpFile" 2>/dev/null
  )

  local cmd=""
  # Since `zopfli` is potentially slow,
  # we only use it for compression when the .tar file is smaller than 50MB
  if (( size < 52428800 )) && (( ${+commands[zopfli]} )); then
    cmd="zopfli"
  else
    if (( ${+commands[pigz]} )); then
      cmd="pigz"
    else
      cmd="gzip"
    fi
  fi

  echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\` ..."
  "${cmd}" -v "$tmpFile" || return 1
  [ -f "$tmpFile" ] && rm "$tmpFile"

  zippedSize=$(
    # BSD `stat`
    stat -f"%z" "$tmpFile.gz" 2>/dev/null
    # GNU `stat`
    stat -c"%s" "$tmpFile.gz" 2>/dev/null
  )

  echo "$tmpFile.gz ($((zippedSize / 1000)) kB) successfully created."
}

# A shorthand for `tree`, with colour, defaulted hidden files and sort (directories first)
tre() {
  tree -aC -I ".git|node_modules" --dirsfirst "$@" | less -FNRX
}

# Update software:
# 1. Update the operating system and its packages
# 2. Update mise-en-place, then the tools it installed and the packages it declares
# 3. Update npm and installed packages
# 4. Update uv installed packages
# 5. Update installed Ruby gems
# 6. Clear `eval` cache
update() {
  (( $+functions[_update_system] )) && _update_system
  mise self-update -y
  mise up
  mise bootstrap packages upgrade
  npm install npm -g
  npm update -g
  uv tool upgrade --all
  if (( $+commands[gem] )); then
    gem update --system
    gem update
    gem cleanup
  fi
  yes | _evalcache_clear
}
