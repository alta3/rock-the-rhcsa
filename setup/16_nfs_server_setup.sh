#!/bin/bash

# Install nfs-utils for NFS server setup
sudo dnf install -y nfs-utils

# Create the shared directory and set appropriate ownership and permissions
sudo mkdir -p /srv/aragorn_share
sudo chown student:student /srv/aragorn_share
sudo chmod 755 /srv/aragorn_share

# Configure the NFS export
echo "/srv/aragorn_share *(rw,sync,no_root_squash)" | sudo tee -a /etc/exports

# Export the NFS share
sudo exportfs -rav

# Start and enable NFS services
sudo systemctl enable --now nfs-server rpcbind

# Set up the NFS_SERVER environment variable with the system's IP address on eth0
echo "export NFS_SERVER=\$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')" >> ~/.bashrc
source ~/.bashrc

echo "Setup complete!"
