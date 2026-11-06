#!/bin/bash

pass=true

# Mounted on /mydata as vfat
mount | grep -q "/mydata type vfat" || pass=false

# Persistent: entry exists in /etc/fstab
grep -q "/mydata" /etc/fstab || pass=false

# Partition is roughly 1G (1073741824 bytes)
size=$(lsblk -bno SIZE "$(findmnt -no SOURCE /mydata)" 2>/dev/null)
[[ "$size" -eq 1073741824 ]] || pass=false

if $pass; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi


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
