#!/bin/bash

# Verify if the NFS share is mounted on /mnt/frodo_mount and has read/write access
if mount | grep -q "/mnt/frodo_mount type nfs" && touch /mnt/frodo_mount/test_rw && rm /mnt/frodo_mount/test_rw; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

