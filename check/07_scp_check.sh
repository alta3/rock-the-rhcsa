#!/bin/bash

# Prompt the user to input the IP address of the remote machine
read -p "Enter the IP address of the remote machine (bchd): " remote_ip

# Check if the file exists in /tmp on the remote machine
if sshpass -p 'alta3' ssh -o StrictHostKeyChecking=no student@$remote_ip '[[ -f /tmp/longfile.txt ]]'; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

