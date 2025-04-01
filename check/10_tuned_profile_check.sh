#!/bin/bash

# Check if the tuned profile is set to the recommended profile
if tuned-adm active | grep -q "$(tuned-adm recommend)"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

