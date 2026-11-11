#!/bin/bash
# ssh_keys_setup.sh (RHCSA practice) - run on rhel-1
# Creates the throwaway user milhouse (password: thrillho) and empties his
# ~/.ssh, so no key is authorized yet. The student then sets up key-based
# login to milhouse@rhel-1 from rhel-2.
# Does not touch sshd, its config, or the student/root accounts.

USER_NAME=milhouse
USER_PASS=thrillho

if ! id "$USER_NAME" &>/dev/null; then
    if ! sudo useradd "$USER_NAME"; then
        echo "Could not create the user $USER_NAME - see the error above."
        exit 1
    fi
fi
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

sudo rm -rf "/home/$USER_NAME/.ssh"

echo "Setup is complete. Begin your task!"
