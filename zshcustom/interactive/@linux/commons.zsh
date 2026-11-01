#!/usr/bin/env zsh

# ALIASES

# Show all IP addresses of local network interfaces
alias ips="ip -brief address"

# FUNCTIONS

# Show all active network interfaces
ifactive() {
  ip -brief link show up
}

# Show the IP address of the interface used to reach the internet
localip() {
  ip -4 route get 1.1.1.1 | awk '{ for (i = 1; i < NF; i++) if ($i == "src") { print $(i + 1); exit } }'
}

# Upgrade packages from apt, for `update`
_update_system() {
  sudo apt update
  sudo apt upgrade
}
