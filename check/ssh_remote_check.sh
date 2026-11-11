#!/bin/bash
# ssh_remote_check.sh (RHCSA practice) - run on rhel-1
# sshd must be running and enabled. Since setup ran, krusty must have
# logged in over SSH from rhel-2, and /home/krusty/heyhey.txt must exist
# and belong to krusty. Read-only.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

USER_NAME=krusty
FILE=/home/krusty/heyhey.txt

systemctl is-active --quiet sshd   || fail
systemctl is-enabled --quiet sshd  || fail

id "$USER_NAME" &>/dev/null                                 || fail
sudo test -f "$FILE"                                        || fail
[[ "$(sudo stat -c %U "$FILE" 2>/dev/null)" == "$USER_NAME" ]] || fail

# Where rhel-2 connects from (one or more addresses).
mapfile -t from_ips < <(getent ahosts rhel-2 | awk '{print $1}' | sort -u)
(( ${#from_ips[@]} )) || fail

since=$(sudo cat /var/tmp/ssh_remote_setup.ts 2>/dev/null)
[[ "$since" =~ ^[0-9]+$ ]] || since=0

found=0
while read -r line; do
    for ip in "${from_ips[@]}"; do
        [[ "$line" == *" for $USER_NAME from $ip port "* ]] && { found=1; break 2; }
    done
done < <(sudo journalctl --since "@$since" --no-pager -q 2>/dev/null \
             | grep -E 'sshd(-session)?\[[0-9]+\]: Accepted [a-z/-]+ for ')

(( found )) || fail
pass
