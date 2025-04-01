#!/bin/bash

# File to check
FILE="/etc/sudoers"

# Check for all three strings
if sudo grep -q "NOPASSWD" "$FILE" && \
   sudo grep -q "systemctl restart httpd" "$FILE" && \
   sudo grep -q "neo" "$FILE"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
