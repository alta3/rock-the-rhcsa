#!/bin/bash
# create_symlink_setup.sh (RHCSA practice)

# Remove any /tmp/passwd_link left over from earlier labs (the RH124
# hard/soft links lab creates the same link), so the check starts clean.
sudo rm -rf -- /tmp/passwd_link

echo "Setup is complete. Begin your task!"
