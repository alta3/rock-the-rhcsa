#!/bin/bash
# newfile_default_check.sh (RHCSA practice)
# A brand-new user must automatically get an empty, readable ~/NEWFILE.
# Creates a throwaway user to test this, then removes it.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

TESTUSER="rhcsa_skel_check"

sudo userdel -r "$TESTUSER" &>/dev/null
if ! sudo useradd -m "$TESTUSER" &>/dev/null; then
    echo "Could not create the temporary test user '$TESTUSER'."
    exit 2
fi

home=$(getent passwd "$TESTUSER" | cut -d: -f6)
result=1
if sudo -u "$TESTUSER" test -f "$home/NEWFILE" &&
   sudo -u "$TESTUSER" test -r "$home/NEWFILE" &&
   ! sudo test -s "$home/NEWFILE"; then
    result=0
fi

sudo userdel -r "$TESTUSER" &>/dev/null

[[ $result -eq 0 ]] || fail
pass
