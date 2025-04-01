#!/bin/bash

# Check if the script file exists and is executable
if [[ -x /home/student/homer_quote.sh ]]; then
    # Check if the scheduled `at` job runs the script at midnight
    if atq | grep -q "00:00"; then
        echo -e "\e[32mSUCCESS!\e[0m"
    else
        echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    fi
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
