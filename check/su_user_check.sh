#!/bin/bash
# su_user_check.sh (RHCSA practice)
# Passes only if someone actually switched to shrek with su after the
# setup script ran (su logs "session opened for user shrek" to the journal).

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

STAMP=/var/tmp/.rhcsa_su_user_start
if [[ ! -s $STAMP ]]; then
    echo "Run the setup script for this task first, then try again."
    exit 2
fi
start=$(<"$STAMP")

id shrek &>/dev/null || fail

sudo journalctl --since "@$start" _COMM=su -o cat 2>/dev/null \
  | grep -Eq 'session opened for user shrek(\(| )' || fail

pass
