#!/bin/bash
# create_symlink_check.sh (RHCSA practice)
# /tmp/passwd_link must be a soft link that resolves to /etc/passwd
# (absolute or relative link both count).

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

[[ -L /tmp/passwd_link ]] || fail
[[ "$(readlink -f /tmp/passwd_link)" == "/etc/passwd" ]] || fail

pass
