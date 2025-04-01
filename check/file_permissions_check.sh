#!/bin/bash

# Check if the file exists
if [[ ! -f /var/tmp/fstab ]]; then
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    exit 1
fi

# Check ownership, group, and permissions
if [[ $(stat -c "%U %G %A" /var/tmp/fstab) == "harry starwars -rw-r--r--" ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
