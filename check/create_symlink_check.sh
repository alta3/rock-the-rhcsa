#!/bin/bash

# Check if a soft link exists in /tmp pointing to /etc/passwd
if [[ -L /tmp/passwd_link && $(readlink /tmp/passwd_link) == "/etc/passwd" ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
