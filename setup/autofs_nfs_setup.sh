#!/bin/bash

# Install required packages
sudo yum install -y nfs-utils autofs

# Start and enable NFS server for testing
sudo systemctl enable --now nfs-server

# Create the NFS export
sudo mkdir -p /srv/nfs
sudo chmod 777 /srv/nfs
echo "This is a test NFS share" | sudo tee /srv/nfs/testfile.txt >/dev/null

# Configure the export
echo "/srv/nfs *(rw,sync,no_root_squash)" | sudo tee /etc/exports >/dev/null
sudo exportfs -r

echo "Setup is complete. Begin your task!"

