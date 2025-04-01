#!/bin/bash

# Check if the GRUB timeout is set to 5 seconds
if sudo grep -q "^GRUB_TIMEOUT=5" /etc/default/grub; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
