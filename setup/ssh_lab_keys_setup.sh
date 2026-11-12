#!/bin/bash
# ssh_lab_keys_setup.sh (RH124 lab: Configure key-based authentication for SSH) - run on rhel-1
# Creates a fresh throwaway user moe (password: flamingmoe) with no SSH keys
# authorized. Re-running it starts the lab over.
# Does not touch sshd, its config, or the student/root accounts.

USER_NAME=moe
USER_PASS=flamingmoe

if id "$USER_NAME" &>/dev/null; then
    sudo loginctl terminate-user "$USER_NAME" &>/dev/null
    sleep 1
    sudo userdel -r "$USER_NAME" &>/dev/null
fi
if ! sudo useradd "$USER_NAME"; then
    echo "Could not create the user $USER_NAME - see the error above."
    exit 1
fi
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

echo "Setup is complete. Begin the lab!"
