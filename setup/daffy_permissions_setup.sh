#!/bin/bash

# Ensure the user "daffy" exists
if ! id "daffy" &>/dev/null; then
    echo "Creating user daffy..."
    sudo useradd daffy
fi

# Ensure home directory exists
sudo mkdir -p /home/daffy
sudo chown daffy:daffy /home/daffy

# Intentionally wrong umask (002) in both files — student must fix both
echo "umask 002" | sudo tee -a /home/daffy/.bashrc > /dev/null
echo "umask 002" | sudo tee -a /home/daffy/.bash_profile > /dev/null
sudo chown daffy:daffy /home/daffy/.bashrc /home/daffy/.bash_profile

echo "Setup complete!"
