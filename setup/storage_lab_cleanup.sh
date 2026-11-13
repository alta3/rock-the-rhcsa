#!/bin/bash
# storage_lab_cleanup.sh (RH124 storage labs) - run on rhel-1
# Puts the two practice disks, /dev/vda and /dev/vdb, back to blank:
#   - unmounts anything mounted from them (and turns off swap on them)
#   - removes every /etc/fstab line that points at them (by UUID, PARTUUID,
#     LABEL or /dev/vd[ab] name); a backup is kept in /etc/fstab.storage-lab.bak
#   - wipes every file system / swap signature and the partition tables
#   - removes the empty mount point directories the labs created
# The system disk (sda) is never touched. Safe to run more than once.

DISKS=(/dev/vda /dev/vdb)
MOUNTDIRS=(/mnt/test /archive)

# Safety: refuse to run if / or /boot lives on one of the practice disks.
for mp in / /boot; do
    src=$(findmnt -n -o SOURCE "$mp" 2>/dev/null)
    parent=$(lsblk -no PKNAME "$src" 2>/dev/null | head -1)
    for d in "${DISKS[@]}"; do
        if [[ "/dev/$parent" == "$d" || "$src" == "$d" ]]; then
            echo "Refusing: $mp is on $d. This script only cleans the practice disks."; exit 1
        fi
    done
done

present=()
for d in "${DISKS[@]}"; do [[ -b "$d" ]] && present+=("$d"); done
[[ ${#present[@]} -gt 0 ]] || { echo "No practice disks found. Nothing to do."; exit 0; }

# Every block device on the practice disks (the disks and their partitions)
mapfile -t devs < <(lsblk -lnpo NAME "${present[@]}" 2>/dev/null)

# 1. Collect identifiers so matching fstab lines can be found
ids=()
for dev in "${devs[@]}"; do
    ids+=("$dev")
    for tag in UUID PARTUUID LABEL; do
        v=$(sudo blkid -s "$tag" -o value "$dev" 2>/dev/null)
        [[ -n "$v" ]] && ids+=("$tag=$v")
    done
done

# 2. Unmount / swapoff anything on the practice disks
for dev in "${devs[@]}"; do
    if swapon --show=NAME --noheadings 2>/dev/null | grep -qx "$dev"; then
        sudo swapoff "$dev" && echo "Turned off swap on $dev"
    fi
    while read -r mp; do
        [[ -n "$mp" ]] || continue
        sudo umount "$mp" && echo "Unmounted $dev from $mp"
    done < <(findmnt -rn -S "$dev" -o TARGET 2>/dev/null)
done

# 3. Remove matching /etc/fstab lines (a backup is kept if anything is removed)
tmp=$(mktemp)
removed=0
while IFS= read -r line || [[ -n "$line" ]]; do
    first=$(awk '{print $1}' <<<"$line")
    first=${first//\"/}
    drop=0
    if [[ -n "$first" && "$first" != \#* ]]; then
        [[ "$first" =~ ^/dev/vd[ab][0-9]*$ ]] && drop=1
        for id in "${ids[@]}"; do [[ "$first" == "$id" ]] && drop=1; done
    fi
    if (( drop )); then
        echo "Removed from /etc/fstab: $line"; removed=1
    else
        printf '%s\n' "$line" >>"$tmp"
    fi
done < /etc/fstab
if (( removed )); then
    sudo cp -a /etc/fstab /etc/fstab.storage-lab.bak
    sudo cp "$tmp" /etc/fstab
fi
rm -f "$tmp"
sudo systemctl daemon-reload

# 4. Wipe signatures: partitions first, then the disks (partition tables)
for d in "${present[@]}"; do
    for p in $(lsblk -lnpo NAME,TYPE "$d" | awk '$2=="part"{print $1}'); do
        sudo wipefs -a -q "$p"
    done
    if [[ -n "$(lsblk -no NAME "$d" | sed 1d)" || -n "$(sudo blkid -p "$d" 2>/dev/null)" ]]; then
        sudo wipefs -a -q "$d" && echo "Wiped $d"
    fi
done
sudo partprobe "${present[@]}" 2>/dev/null
sudo udevadm settle

# 5. Remove the lab's mount point directories if they are empty
for m in "${MOUNTDIRS[@]}"; do
    [[ -d "$m" ]] && ! mountpoint -q "$m" && sudo rmdir "$m" 2>/dev/null && echo "Removed empty directory $m"
done

if sudo findmnt --verify >/dev/null 2>&1; then
    echo "Cleanup is complete. /etc/fstab checks out and the practice disks are blank."
else
    echo "Cleanup finished, but 'sudo findmnt --verify' reports a problem. Check /etc/fstab."
    exit 1
fi
