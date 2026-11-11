#!/bin/bash
# boot_target_setup.sh (RHCSA practice)
# Makes graphical.target the default boot target, so the student has to
# change it back to multi-user.target. Only the default is changed: the
# running system is left alone (no isolate), and no GUI is installed, so
# even if the student reboots before fixing it, the VM still comes up
# normally with SSH.

if ! sudo systemctl set-default graphical.target &>/dev/null; then
    echo "Could not change the default target - ask your instructor."
    exit 1
fi

echo "Setup is complete. Begin your task!"
