#!/bin/bash
# storage_lab_task_check.sh (RH124 storage labs, RHCSA task) - run on rhel-1
# Task: /dev/vda gets a GPT partition table and a ~2 GiB partition, formatted
# XFS, mounted on /archive now and listed in /etc/fstab by UUID so it mounts
# at boot. /archive/ready.txt exists on that file system.
# Prints which requirement failed, so students know where to look.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m  ($1)"; exit 1; }

# 1. GPT partition table on /dev/vda
[[ "$(lsblk -dno PTTYPE /dev/vda 2>/dev/null)" == "gpt" ]] || fail "/dev/vda does not have a GPT partition table"

# 2. /archive is mounted right now, from a partition on /dev/vda, as xfs
src=$(findmnt -n -o SOURCE --mountpoint /archive 2>/dev/null)
[[ -n "$src" ]] || fail "nothing is mounted on /archive"
[[ "$(lsblk -no PKNAME "$src" 2>/dev/null)" == "vda" ]] || fail "/archive is not mounted from a partition on /dev/vda"
[[ "$(lsblk -no TYPE "$src")" == "part" ]] || fail "/archive is not mounted from a partition"
[[ "$(findmnt -n -o FSTYPE --mountpoint /archive)" == "xfs" ]] || fail "/archive is not an XFS file system"

# 3. About 2 GiB: 2 GB (2,000,000,000 bytes) - 5% up to 2 GiB + 5%
size=$(lsblk -bno SIZE "$src" 2>/dev/null)
(( size >= 1900000000 && size <= 2254857830 )) || fail "the partition is not about 2 GiB"

# 4. Persistent: an uncommented fstab line for /archive that uses UUID= and
#    resolves to the device mounted now
line=$(awk '$1 !~ /^#/ && $2=="/archive"' /etc/fstab)
[[ -n "$line" ]] || fail "no /etc/fstab line for /archive"
[[ "$(awk '{print $1}' <<<"$line")" == UUID=* ]] || fail "the /etc/fstab line for /archive does not use UUID="
fstab_src=$(findmnt --fstab --evaluate -n -o SOURCE --mountpoint /archive 2>/dev/null)
[[ "$(readlink -f "$fstab_src")" == "$(readlink -f "$src")" ]] || fail "the UUID in /etc/fstab is not the UUID of the mounted partition"
sudo findmnt --verify >/dev/null 2>&1 || fail "'sudo findmnt --verify' reports a problem in /etc/fstab"

# 5. The file lives on that file system
[[ -f /archive/ready.txt ]] || fail "/archive/ready.txt does not exist"
[[ "$(df --output=source /archive/ready.txt | tail -1)" == "$src" ]] || fail "/archive/ready.txt is not on the new file system"

pass
