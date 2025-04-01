#!/bin/bash

# Create the service file with incorrect context
sudo touch /etc/systemd/system/container-pikachu.service

# Set an incorrect SELinux context type for demonstration
sudo chcon -t var_t /etc/systemd/system/container-pikachu.service

echo "Setup complete!"
