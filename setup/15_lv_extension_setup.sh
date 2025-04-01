#!/bin/bash

# Prepare /dev/xvdc by creating a physical volume
sudo pvcreate /dev/xvdc

# Create a volume group named vg-jedi on /dev/xvdc
sudo vgcreate vg-jedi /dev/xvdc

# Create a logical volume named lv-yoda with a small initial size on vg-jedi
sudo lvcreate -L 1G -n lv-yoda vg-jedi

# Format lv-yoda with ext4 filesystem
sudo mkfs.ext4 /dev/vg-jedi/lv-yoda

echo "Setup complete!"
