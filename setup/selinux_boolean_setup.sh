#!/bin/bash

# Ensure the SELinux Boolean is disabled
sudo setsebool -P logrotate_read_inside_containers &>/dev/null

echo "Setup is complete. Begin your task!"
