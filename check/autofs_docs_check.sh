#!/bin/bash
# autofs_docs_check.sh (RHCSA practice)
# autofs must be installed, running and enabled. /shares must be an autofs
# (indirect map) mount point, and reading /shares/docs must mount
# localhost:/exports/docs read-only. No /etc/fstab entry allowed.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

FILE_TEXT="Springfield Nuclear Power Plant: safety manual, page 1 of 1"

rpm -q autofs &>/dev/null           || fail
systemctl is-active --quiet autofs  || fail
systemctl is-enabled --quiet autofs || fail

grep -qE '^[^#]*[[:space:]]/shares(/|[[:space:]]|$)' /etc/fstab && fail

# Indirect map: /shares itself is the autofs mount point.
[[ "$(findmnt -n -o FSTYPE --mountpoint /shares 2>/dev/null)" == "autofs" ]] || fail

# Touching the key triggers the NFS mount.
[[ "$(timeout 15 cat /shares/docs/manual.txt 2>/dev/null)" == "$FILE_TEXT" ]] || fail

# Because the NFS server is this same machine, autofs skips NFS and
# bind-mounts the directory. Accept that (same device and inode as
# /exports/docs), or a real NFS mount of the export from this host by any
# local name (localhost, 127.0.0.1, the hostname or its IP).
read -r fstype source options < <(findmnt -n -o FSTYPE,SOURCE,OPTIONS --mountpoint /shares/docs 2>/dev/null | tail -n 1)
[[ -n "$fstype" ]] || fail
if [[ "$fstype" == nfs* ]]; then
    [[ "$source" == *:/exports/docs || "$source" == *:/exports/docs/ ]] || fail
else
    [[ "$(stat -c %d:%i /shares/docs 2>/dev/null)" == "$(stat -c %d:%i /exports/docs 2>/dev/null)" ]] || fail
fi
[[ ",$options," == *",ro,"* ]] || fail

pass
