#!/bin/bash

# Check password expiration policy
PASS_MAX_DAYS=$(sudo grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
MIN_LEN=$(sudo grep "^minlen" /etc/security/pwquality.conf | awk -F "=" '{print $2}')

if [[ "$PASS_MAX_DAYS" -eq 90 && "$MIN_LEN" -eq 8 ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
