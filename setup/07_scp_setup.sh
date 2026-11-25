#!/bin/bash

if ! command -v sshpass &> /dev/null; then
    sudo yum install -y sshpass
fi

# Create the file to copy (no external download)
seq 1 100000 | sed 's/^/line /' > /home/student/longfile.txt

# Set BCHD's student password to match the lab text / check script
read -p "Enter the IP address of the remote machine (bchd): " remote_ip
if ssh -o BatchMode=yes -o StrictHostKeyChecking=no student@"$remote_ip" \
     "echo 'student:alta3' | sudo chpasswd"; then
    echo "Setup complete!"
else
    echo -e "\e[31mSetup failed: could not reach bchd at $remote_ip\e[0m" >&2
    exit 1
fi
