#!/bin/bash

# Create a dummy interface for testing
sudo nmcli connection add type dummy ifname dummy0 con-name dummy0 ip4 192.168.50.100/24 gw4 192.168.50.1
sudo nmcli connection modify dummy0 ipv4.dns "8.8.8.8"

echo "Setup is complete. Begin your task!"
