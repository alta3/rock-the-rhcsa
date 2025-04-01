#!/bin/bash

# Set the default and current boot target to graphical.target
sudo systemctl set-default graphical.target
sudo systemctl isolate graphical.target

echo "Setup complete!"

