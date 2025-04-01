#!/bin/bash

# Check if the NTP server is set to time.cloudflare.com
if sudo chronyc sources -v | grep -q "time.cloudflare.com"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
