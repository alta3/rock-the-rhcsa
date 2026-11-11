#!/bin/bash
# ssh_keys_check.sh (RHCSA practice) - run on rhel-2 as the student
# ~/.ssh/milhouse_key (no passphrase) and its .pub must exist, and that key
# alone must log in to milhouse@rhel-1 with no password.
# Changes nothing: it doesn't even save rhel-1's host key to known_hosts.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

KEY="$HOME/.ssh/milhouse_key"

[[ -f "$KEY" && -f "$KEY.pub" ]] || fail

# The key alone, no password, no agent, no prompts, no hanging.
timeout 30 ssh -i "$KEY" \
    -o IdentitiesOnly=yes -o IdentityAgent=none \
    -o BatchMode=yes -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no \
    -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR \
    -o ConnectTimeout=10 \
    milhouse@rhel-1 true </dev/null &>/dev/null || fail

pass
