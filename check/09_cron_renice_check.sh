#!/bin/bash

# Get the PID of the cron process
cron_pid=$(pgrep cron)

# Check if the cron process has been reniced to priority 10
if [[ $(ps -o ni= -p "$cron_pid" | tr -d ' ') -eq 10 ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

