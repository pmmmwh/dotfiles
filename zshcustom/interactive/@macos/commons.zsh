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

# Show current public IP address
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
# Show all IP addresses of local network interfaces
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# If macOS has no command for canonical hex dump, set the alias as a fallback
(( ${+commands[hd]} )) || alias hd="hexdump -C"

# If macOS has no `md5sum`, use `md5` as a fallback
(( ${+commands[md5sum]} )) || alias md5sum="md5"

# If macOS has no `sha1sum`, use `shasum` as a fallback
(( ${+commands[sha1sum]} )) || alias sha1sum="shasum"

# FUNCTIONS

# Show all active network interfaces
ifactive() {
  # awk rather than grep: a match spans the whole indented block, not one line
  ifconfig | awk '
    /^[^\t]/ { if (block ~ /status: active/) printf "%s", block; block = "" }
              { block = block $0 "\n" }
    END       { if (block ~ /status: active/) printf "%s", block }
  '
}

# Show the IP address of the currently active network interface
localip() {
  ipconfig getifaddr "$(netstat -rn | grep default | awk '{print $NF}' | head -1)"
}

# Get macOS Software Updates and update apps from App Store, for `update`
_update_system() {
  sudo softwareupdate -i -a
  mas upgrade
}
