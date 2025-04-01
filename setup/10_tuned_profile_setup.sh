#!/bin/bash

# Install tuned if not already installed
sudo yum install -y tuned > /dev/null 2>&1

# Ensure tuned is started and enabled
sudo systemctl start tuned > /dev/null 2>&1
sudo systemctl enable tuned > /dev/null 2>&1

# Set the tuned profile to balanced
sudo tuned-adm profile balanced > /dev/null 2>&1

# Final output
echo "Setup complete!"
