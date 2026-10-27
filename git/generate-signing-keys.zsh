#!/usr/bin/env -S zsh -f

() {
  # Get the current execution context
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)

  # Source commons (e.g. logging)
  for libraryFile ($SCRIPT_DIR/../_lib/*.zsh(N)); do
    source $libraryFile
  done

  if (( ! $+commands[gpg] )); then
    logger "error" "gpg is not on PATH - install GPG Suite first."
    exit 1
  fi

  # Generate a signing key for each git identity that does not have one -
  # with no `user.signingKey`, git signs with the key matching `user.name <user.email>`
  local credentials name email
  for credentials in ~/.gitcredentials.{personal,work}; do
    name=$(git config --file $credentials user.name)
    email=$(git config --file $credentials user.email)

    # The full uid, not just the address:
    # with no `user.signingKey`, git asks gpg for `name <email>`,
    # so a key carrying the address under another name is no use
    if gpg --list-secret-keys "$name <$email>" &>/dev/null; then
      continue
    fi

    logger "info" "Generating a GPG signing key for $email ..."
    gpg --batch --quick-generate-key "$name <$email>" ed25519 sign 2y || exit 1

    logger "success" "Successfully generated a GPG signing key for $email"
    logger "info" "Add it to GitHub with:"
    printf "  gpg --armor --export '<%s>' | gh gpg-key add -\n" $email
  done
}
