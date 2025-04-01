#!/bin/bash

# Set SELinux to permissive in config file
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config >/dev/null 2>&1

# Temporarily apply permissive mode
sudo setenforce 0 >/dev/null 2>&1

echo "Setup complete!"
