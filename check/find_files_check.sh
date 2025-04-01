#!/bin/bash

# Directory to check
DIR="/root/findresults"

FILE_COUNT=$(sudo find "$DIR" -mindepth 1 -maxdepth 1 -type f | wc -l)

if [ "$FILE_COUNT" -ge 8 ] && [ "$FILE_COUNT" -le 9 ]; then
    echo -e "\e[32mSUCCESS!\e[0m"
    exit 0
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    exit 1
fi
