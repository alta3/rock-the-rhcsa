#!/bin/bash
# create_partition_check.sh (RHCSA practice)
# A ~1 GB partition, formatted vfat, mounted on /mydata now and listed in
# /etc/fstab so it mounts at boot.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# Mounted right now, as vfat
src=$(findmnt -n -o SOURCE --mountpoint /mydata 2>/dev/null)
[[ -n "$src" ]] || fail
[[ "$(findmnt -n -o FSTYPE --mountpoint /mydata)" == "vfat" ]] || fail

# Persistent: a real (uncommented) fstab entry for /mydata that resolves to
# the same device that is mounted now
fstab_src=$(findmnt --fstab --evaluate -n -o SOURCE --mountpoint /mydata 2>/dev/null)
[[ -n "$fstab_src" ]] || fail
[[ "$(readlink -f "$fstab_src")" == "$(readlink -f "$src")" ]] || fail

# It's a partition of about 1 GB: anything from 1 GB (1,000,000,000 bytes)
# minus 5% to 1 GiB (1,073,741,824 bytes) plus 5% is accepted.
[[ "$(lsblk -no TYPE "$src" 2>/dev/null)" == "part" ]] || fail
size=$(lsblk -bno SIZE "$src" 2>/dev/null)
[[ -n "$size" ]] || fail
(( size >= 950000000 && size <= 1127428915 )) || fail

pass


## Steps to succeed

## 1. Confirm the disk is blank
#lsblk /dev/vdb
#
## 2. Create a GPT label and a 1 GiB partition
#sudo parted /dev/vdb mklabel gpt
#sudo parted /dev/vdb mkpart primary 1MiB 1025MiB
#
## 3. Make sure the kernel sees the new partition
#sudo partprobe /dev/vdb
#lsblk /dev/vdb          # should show vdb1 at 1G
#
## 4. Format as vfat
#sudo mkfs.vfat /dev/vdb1
#
## 5. Create the mount point
#sudo mkdir /mydata
#
## 6. Get the UUID
#sudo blkid /dev/vdb1
#
## 7. Add to /etc/fstab (replace XXXX-XXXX with the UUID from blkid)
#echo 'UUID=XXXX-XXXX  /mydata  vfat  defaults  0 0' | sudo tee -a /etc/fstab
#
## 8. Reload systemd and mount everything from fstab
#sudo systemctl daemon-reload
#sudo mount -a
#
## 9. Verify
#findmnt /mydata
#df -h /mydata
