#!/bin/bash

# Check if the file dasboot.txt exists and contains boot logs from journalctl
if [[ -f /home/student/dasboot.txt ]] && [[ $(wc -l < /home/student/dasboot.txt) -gt 100 ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
