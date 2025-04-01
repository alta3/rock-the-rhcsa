#!/bin/bash

# Check if firewalld is running, eth0 is in the home zone, and home is the default zone
if sudo firewall-cmd --state &>/dev/null && \
   sudo firewall-cmd --get-default-zone | grep -q "home" && \
   sudo firewall-cmd --zone=home --list-interfaces | grep -q "eth0"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
