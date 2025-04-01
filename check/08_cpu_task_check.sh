#!/bin/bash

# Check if there are no `yes` processes running, indicating the task was terminated
if ! pgrep yes > /dev/null; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

