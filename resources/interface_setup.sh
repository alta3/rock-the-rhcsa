#!/bin/bash
# interface_setup.sh (RH124 lab: Configure IP addresses and hostnames) - run on rhel-1 with sudo
# Creates the practice interface ens4 and its NetworkManager connection, also named ens4.
# Re-running it resets ens4 to a blank state (no IP address, gateway or DNS).
# Undo everything with interface_cleanup.sh.
#
# ens4 is a Linux *bridge* with no ports. It's not connected to anything, so
# nothing you set on it can affect the VM's real network (eth0). It's a bridge,
# not a dummy interface, because nmtui can't see dummy connections; it lists
# and edits bridges just fine.
set -euo pipefail
IFACE="ens4"
LABCONF=/etc/NetworkManager/conf.d/90-rhcsa-lab-ens4-only.conf

# Some lab images ship with NetworkManager masked, and their real network
# interface (eth0) configured some other way. If we just start NetworkManager
# there, it takes over eth0 and re-runs DHCP (which can drop your SSH session)
# and rewrites /etc/resolv.conf. So when NetworkManager wasn't already in
# charge, tell it to manage only the practice interface and leave DNS alone.
if ! systemctl is-active --quiet NetworkManager || [[ -f "$LABCONF" ]]; then
  sudo tee "$LABCONF" >/dev/null <<EOF
# Created by the RHCSA lab setup (interface_setup.sh).
# NetworkManager was not managing this VM's network before the lab, so it
# only manages the practice interface $IFACE and leaves DNS untouched.
# interface_cleanup.sh removes this file and masks NetworkManager again.
[main]
dns=none

[keyfile]
unmanaged-devices=except:interface-name:$IFACE
EOF
fi

# Make sure NetworkManager is available (some lab images mask it)
sudo systemctl unmask NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl restart NetworkManager
# -s: wait for NetworkManager to finish starting (not for a connected device,
# which never comes if it isn't managing any real interface).
nm-online -s -q -t 30 || { echo "NetworkManager did not come up"; exit 1; }

echo "=== Resetting $IFACE for RHCSA lab ==="

# Delete old profiles named ens4 (from this or an older version of the lab)
for c in $(nmcli -t -f NAME con show | grep "^$IFACE$" || true); do
  sudo nmcli con delete "$c" || true
done

# Delete the old device if it still exists (an older version made it a dummy)
if ip link show "$IFACE" >/dev/null 2>&1; then
  sudo ip link delete "$IFACE" || true
fi

# Create a clean NetworkManager-managed bridge connection and device.
# No IP settings yet: the student adds them during the lab.
sudo nmcli connection add type bridge ifname "$IFACE" con-name "$IFACE" \
  bridge.stp no ipv4.method disabled ipv6.method disabled

# Bring it up so students can modify it during the lab
sudo nmcli connection up "$IFACE"

echo "Lab setup complete!"
