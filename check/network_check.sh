#!/bin/bash

# Check hostname
if [[ $(hostnamectl hostname) == "millennium-falcon" ]]; then
    # Check IP address, gateway, and DNS
    if sudo nmcli connection show ens4 | grep -q "192.168.50.100" &&
       sudo nmcli connection show ens4 | grep -q "192.168.50.1" &&
       sudo nmcli connection show ens4 | grep -q "8.8.8.8"; then
        echo -e "\e[32mSUCCESS!\e[0m"
    else
        echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    fi
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
