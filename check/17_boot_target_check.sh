#!/bin/bash

# Check if the default boot target is set to multi-user.target
if [[ $(systemctl get-default) == "multi-user.target" ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

