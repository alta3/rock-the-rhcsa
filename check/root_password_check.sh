#!/bin/bash
# root_password_check.sh (RHCSA practice)
# root's password must be "eatmyshorts", and /etc/shadow must still have
# its SELinux label (shadow_t). If the label is wrong, /.autorelabel was
# skipped and logins can break.
# Read-only: it compares the stored hash and changes nothing.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

WANT='eatmyshorts'

hash=$(sudo getent shadow root 2>/dev/null | cut -d: -f2)
[[ "$hash" == \$* ]] || fail     # locked (!), empty, or no password

# Hash the expected password with the stored salt and compare.
# Python's crypt uses the system's libcrypt, so any hash type works.
WANT="$WANT" HASH="$hash" python3 -W ignore -c '
import crypt, os, sys
sys.exit(0 if crypt.crypt(os.environ["WANT"], os.environ["HASH"]) == os.environ["HASH"] else 1)
' 2>/dev/null || fail

[[ "$(stat -c %C /etc/shadow 2>/dev/null)" == *:shadow_t:* ]] || fail

pass
