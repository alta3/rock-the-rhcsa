#!/bin/bash
set -euo pipefail
IFACE="ens4"

echo "=== Resetting $IFACE for RHCSA lab ==="

# Delete old profiles named ens4
for c in $(nmcli -t -f NAME con show | grep "^$IFACE$"); do
  sudo nmcli con delete "$c" || true
done

# Delete old device if it exists
if ip link show "$IFACE" >/dev/null 2>&1; then
  sudo ip link delete "$IFACE" type dummy || true
fi

# Create a clean NetworkManager-managed dummy connection and device
sudo nmcli connection add type dummy ifname "$IFACE" con-name "$IFACE" \
  ipv4.method disabled ipv6.method link-local

# Bring it up so students can modify it during the lab
sudo nmcli connection up "$IFACE"

echo "Lab setup complete!"
