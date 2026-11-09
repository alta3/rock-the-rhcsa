#!/bin/bash
# sudo_user_setup.sh (RHCSA practice)

# Create the user 'neo' if it doesn't exist
if ! id "neo" &>/dev/null; then
    sudo useradd neo
fi

# Install httpd so the rule can actually be tested
if ! rpm -q httpd &>/dev/null; then
    sudo dnf install -y -q httpd
fi

echo "Setup is complete. Begin your task!"
