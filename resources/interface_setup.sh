#!/bin/bash

# Define the interface name
INTERFACE="ens4"
CON_NAME="ens4"

# Check if the interface exists
if ip link show $INTERFACE > /dev/null 2>&1; then
    echo "Interface $INTERFACE exists. Tearing it down..."
    nmcli connection delete $CON_NAME > /dev/null 2>&1 || true
    ip link delete $INTERFACE
    echo "Interface $INTERFACE removed."
else
    echo "Interface $INTERFACE does not exist. Proceeding to create it..."
fi

# Create the bridge interface
echo "Creating bridge interface $INTERFACE..."
nmcli connection add type bridge ifname $INTERFACE con-name $CON_NAME

# Bring up the interface
echo "Bringing up interface $INTERFACE..."
nmcli connection up $CON_NAME

# Verify the interface is up
if ip link show $INTERFACE | grep -q "UP"; then
    echo "Interface $INTERFACE created and active."
else
    echo "Failed to create or activate $INTERFACE."
    exit 1
fi
