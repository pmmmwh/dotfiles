#!/usr/bin/env -S zsh -f

() {
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh(N)); do
    source $libraryFile
  done

  if [[ $OSTYPE != darwin* ]]; then
    logger "error" "Secure Enclave keys only exist on macOS."
    exit 1
  fi

  if [[ ! -S $SSH_AUTH_SOCK ]]; then
    logger "error" "No ssh-agent socket found in SSH_AUTH_SOCK."
    exit 1
  fi

  local -a identities=($@)
  (( $#identities )) || identities=(personal work)

  # The provider prompts for a PIN even for keys without one; an empty answer is accepted
  load_keys() {
    SSH_ASKPASS=/usr/bin/true SSH_ASKPASS_REQUIRE=force \
      /usr/bin/ssh-add -K -S /usr/lib/ssh-keychain.dylib < /dev/null > /dev/null 2>&1
  }

  fingerprint_of() {
    /usr/sbin/sc_auth list-ctk-identities -t ssh | /usr/bin/awk -v label=$1 '$4 == label { print $2; exit }'
  }

  public_key_of() {
    local line
    /usr/bin/ssh-add -L | while read -r line; do
      if [[ $(/usr/bin/ssh-keygen -lf /dev/stdin <<< $line | /usr/bin/awk '{ print $2 }') == $1 ]]; then
        set -- ${=line}
        print -r -- "$1 $2"
        return
      fi
    done
  }

  local identity label failed=0
  for identity in $identities; do
    label=git-signing-$identity
    if [[ -z $(fingerprint_of $label) ]]; then
      logger "info" "Creating Secure Enclave key $label ..."
      /usr/sbin/sc_auth create-ctk-identity -l $label -N $label -k p-256-ne -t none || failed=1
    fi
  done

  load_keys

  local fingerprint key pub
  for identity in $identities; do
    label=git-signing-$identity
    fingerprint=$(fingerprint_of $label)
    key=${fingerprint:+$(public_key_of $fingerprint)}

    if [[ -z $key ]]; then
      logger "error" "Could not read the public key for $label; rerun to retry."
      failed=1
      continue
    fi

    # Saved as a file, not a mise var: templates read files again when the dotfiles are applied,
    # after this runs as a pre-dotfiles hook, while vars are only read when mise starts
    pub=$HOME/.ssh/$label.pub
    if [[ ! -f $pub || $(< $pub) != $key ]]; then
      mkdir -p -m 700 $HOME/.ssh
      print -r -- $key > $pub
      logger "success" "$label: $key"
      logger "info" "Register it with: echo '$key' | gh ssh-key add - --type signing --title \"$(/usr/sbin/scutil --get ComputerName) ($identity)\""
    fi
  done

  exit $failed
} "$@"
