#!/bin/bash
# file_permissions_check.sh (RHCSA practice)
# /var/tmp/fstab: owner harry, group starwars, mode 644 (rw-r--r--).

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

[[ -f /var/tmp/fstab ]] || fail
[[ $(stat -c "%U %G %A" /var/tmp/fstab) == "harry starwars -rw-r--r--" ]] || fail

pass
