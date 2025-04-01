#!/bin/bash

# Identify the swap partition on /dev/sdb
SWAP_PART=$(lsblk -no NAME,TYPE,SIZE | awk '$2 == "part" && $3 == "500M" {print $1}' | head -n 1)

if [[ -z "$SWAP_PART" ]]; then
   echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    exit 1
fi

SWAP_DEV="/dev/${SWAP_PART//[^a-zA-Z0-9]/}"  # Remove unexpected characters from partition name

# Check if swap is enabled
if ! sudo swapon --show=NAME | grep -qw "$SWAP_DEV"; then
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    exit 1
fi

# Get UUID of the swap partition
SWAP_UUID=$(sudo blkid -s UUID -o value "$SWAP_DEV")

# Check if swap is in /etc/fstab, either by device path or UUID
if ! sudo grep -Eq "($SWAP_DEV|UUID=$SWAP_UUID).*swap" /etc/fstab; then
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    exit 1
fi

echo -e "\e[32mSUCCESS!\e[0m"
exit 0
