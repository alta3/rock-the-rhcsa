#!/bin/bash
# su_user_setup.sh (RHCSA practice)

# Create the user 'shrek' if it does not already exist
if ! id "shrek" &>/dev/null; then
    sudo useradd shrek
    echo "User 'shrek' has been created."
else
    echo "User 'shrek' already exists."
fi

# Set a password for 'shrek' (to keep it simple, set it to 'shrek')
echo "shrek:shrek" | sudo chpasswd

# Record when the task started, so the check only counts a switch to
# shrek made after this point.
date +%s | sudo tee /var/tmp/.rhcsa_su_user_start >/dev/null

echo "Setup is complete. Begin your task!"
