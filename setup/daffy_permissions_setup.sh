#!/bin/bash

# Ensure the user "daffy" exists
if ! id "daffy" &>/dev/null; then
    echo "Creating user daffy..."
    sudo useradd daffy
fi

# Ensure home directory exists
sudo mkdir -p /home/daffy
sudo chown daffy:daffy /home/daffy

# Set the umask to 022 (incorrect for the test requirements)
echo "umask 022" | sudo tee -a /home/daffy/.bashrc > /dev/null
echo "umask 022" | sudo tee -a /home/daffy/.bash_profile > /dev/null
sudo chown daffy:daffy /home/daffy/.bashrc /home/daffy/.bash_profile

# Also apply globally for redundancy (with the wrong umask)
echo 'if [ "$(id -un)" == "daffy" ]; then umask 022; fi' | sudo tee /etc/profile.d/daffy_umask.sh > /dev/null
sudo chmod +x /etc/profile.d/daffy_umask.sh

echo "Setup complete!"
