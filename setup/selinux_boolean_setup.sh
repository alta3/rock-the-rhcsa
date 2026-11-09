#!/bin/bash
# selinux_boolean_setup.sh (RHCSA practice)

# Start the task with the boolean off, both now and persistently.
sudo setsebool -P logrotate_read_inside_containers off

echo "Setup is complete. Begin your task!"
