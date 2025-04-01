#!/bin/bash

# Check if the user 'shrek' exists
if id "shrek" &>/dev/null; then
    # Try switching to the user 'shrek' using 'su'
    sudo su -c "whoami" - shrek &>/dev/null

    if [[ $? -eq 0 ]]; then
        echo -e "\e[32mSUCCESS!\e[0m"
    else
        echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    fi
else
    echo -e "\e[31mNO PASS- TRY AGAIN! The user 'shrek' does not exist.\e[0m"
fi
