#!/bin/bash

# Create the user 'frank' if it doesn't exist
if ! sudo id "frank" &>/dev/null; then
    sudo useradd frank
fi

# Create random files owned by 'frank' in various locations
sudo touch /tmp/frank_file1 /var/log/frank_file2 /home/frank_file3
sudo chown frank:frank /tmp/frank_file1 /var/log/frank_file2 /home/frank_file3

# Create a hidden file owned by 'frank'
sudo touch /home/.frank_hidden
sudo chown frank:frank /home/.frank_hidden

# Output minimal success message
echo "Setup is complete. Begin your task!"
