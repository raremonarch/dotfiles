#!/bin/bash
# Mount hermes-code over sshfs at login.
# Retries for a few minutes because the ed25519 key needed for bigbox.lan
# isn't in the agent until `ssh-add ~/.ssh/ed25519` is run post-login.
mountpoint -q ~/code/hermes-code && exit 0

for i in $(seq 1 24); do
    sshfs bigbox.lan:/home/hermes-1/code ~/code/hermes-code -o reconnect && exit 0
    sleep 5
done
