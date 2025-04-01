#!/bin/bash

# Create a test user to check for NEWFILE in their home directory
if [[ -f /etc/skel/NEWFILE ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
