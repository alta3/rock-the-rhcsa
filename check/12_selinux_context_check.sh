#!/bin/bash

# Check if the SELinux context for the file is set to etc_t
if ls -Z /etc/systemd/system/container-pikachu.service | grep -q "systemd_unit_file_t"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
