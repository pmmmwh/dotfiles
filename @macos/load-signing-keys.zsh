#!/usr/bin/env -S zsh -f

# Secure Enclave keys are only offered to ssh-agent once loaded from the provider; the PIN prompt takes an empty answer
export SSH_ASKPASS=/usr/bin/true SSH_ASKPASS_REQUIRE=force
exec /usr/bin/ssh-add -K -S /usr/lib/ssh-keychain.dylib < /dev/null > /dev/null 2>&1
