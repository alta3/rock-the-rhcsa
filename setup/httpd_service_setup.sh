#!/bin/bash
# httpd_service_setup.sh (RHCSA practice)

# Start the task without httpd installed
if rpm -q httpd &>/dev/null; then
    sudo systemctl disable --now httpd &>/dev/null
    if ! sudo dnf remove -y -q httpd; then
        echo "Could not remove httpd - see the error above."
        exit 1
    fi
fi

echo "Setup is complete. Begin your task!"
