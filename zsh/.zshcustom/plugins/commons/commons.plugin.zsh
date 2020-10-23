#!/usr/bin/env zsh

# ALIASES

# Kill all the tabs in Chrome to free up memory
# Explanation: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper (Renderer) --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empties trash files on the machine:
# - Empty the Trash on all mounted volumes and the main HDD
# - Clear macOS System Logs to improve shell startup speed
# - Clear download history from system quarantine
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Show all active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Show current public IP address
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
# Show all IP addresses of local network interfaces
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show all ports that are currently listning by a process
alias listeningports="sudo lsof -iTCP -sTCP:LISTEN -nP"

# An intuitive map function
# Usage (to list all directories that contain a certain file):
# `find . -name .gitattributes | map dirname`
alias map="xargs -n1"

# Merge PDF files, preserving hyperlinks
# Usage: `mergepdf input{1,2,3}.pdf`
alias mergepdf="gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf"

# Prints all PATH entries, each on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec ${SHELL} -l'

# Update software:
# 1. Get macOS Software Updates
# 2. Update Homebrew and installed formulae
# 3. Update apps from App Store
# 4. Update npm and installed packages
# 5. Update yarn installed packages
# 6. Update installed Ruby gems
alias update="sudo softwareupdate -i -a; brew update; brew upgrade; mas upgrade; npm install npm -g; npm update -g; yarn global upgrade; sudo gem update --system; sudo gem update; sudo gem cleanup"

# Get current week (number)
alias week="date +%V"

# If macOS has no command for canonical hex dump, set the alias as a fallback
(( ${+commands[hd]} )) || alias hd="hexdump -C"

# If macOS has no `md5sum`, use `md5` as a fallback
(( ${+commands[md5sum]} )) || alias md5sum="md5"

# If macOS has no `sha1sum`, use `shasum` as a fallback
(( ${+commands[sha1sum]} )) || alias sha1sum="shasum"

# Simple HTTP request client for the shell
for method (GET HEAD POST PUT DELETE TRACE OPTIONS); do
  alias "$method=lwp-request -m '$method'"
done

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

# Show the IP address of the currently active network interface
localip() {
  ipconfig getifaddr "$(netstat -rn | grep default | awk '{print $NF}' | head -1)"
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

# Use `diff` from Git instead of default (if available)
if (( ${+commands[git]} )); then
  diff() {
    git diff --no-index --color-words "$@"
  }
fi
