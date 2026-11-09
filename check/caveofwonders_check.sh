#!/bin/bash
# caveofwonders_check.sh (RHCSA practice)
# /home/student/caveofwonders:
#   - group agrabah, with setgid so new files/dirs inherit agrabah
#   - agrabah members can read/write/execute
#   - nobody outside agrabah has access (root excepted). That includes the
#     directory's owner, unless the owner is root or an agrabah member.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

DIR=/home/student/caveofwonders

sudo test -d "$DIR" || fail
read -r mode owner group < <(sudo stat -c '%a %U %G' "$DIR")

[[ "$group" == "agrabah" ]] || fail

mode=$(printf '%04d' "$mode")
special=${mode:0:1}; u=${mode:1:1}; g=${mode:2:1}; o=${mode:3:1}

(( special & 2 )) || fail      # setgid
[[ "$g" == "7" ]]  || fail      # group rwx
[[ "$o" == "0" ]]  || fail      # others: nothing

# The owner may only have access if they are root or in agrabah.
if [[ "$u" != "0" && "$owner" != "root" ]]; then
    [[ " $(id -Gn "$owner" 2>/dev/null) " == *" agrabah "* ]] || fail
fi

pass
