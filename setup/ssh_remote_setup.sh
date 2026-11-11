#!/bin/bash
# ssh_remote_setup.sh (RHCSA practice) - run on rhel-1
# Creates the throwaway user krusty (password: heyheyhey) for the student
# to log in to over SSH from rhel-2, removes any earlier answer, and
# records the start time, so only logins after this count.
# Does not touch sshd, its config, or the student/root accounts.

USER_NAME=krusty
USER_PASS=heyheyhey

if ! id "$USER_NAME" &>/dev/null; then
    if ! sudo useradd "$USER_NAME"; then
        echo "Could not create the user $USER_NAME - see the error above."
        exit 1
    fi
fi
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

sudo rm -f "/home/$USER_NAME/heyhey.txt"
date +%s | sudo tee /var/tmp/ssh_remote_setup.ts >/dev/null

echo "Setup is complete. Begin your task!"
