#!/bin/bash
set -euo pipefail
IFACE="ens4"

echo "=== Resetting $IFACE for RHCSA lab ==="

# Delete old profiles named ens4
for c in $(nmcli -t -f NAME con show | grep "^$IFACE$"); do
  sudo nmcli con delete "$c" || true
done

# Create dummy device if missing
if ! ip link show "$IFACE" >/dev/null 2>&1; then
  sudo ip link add "$IFACE" type dummy
fi
sudo ip link set "$IFACE" up

# Add a clean ethernet profile *explicitly bound to ens4*
sudo nmcli con add type ethernet con-name "$IFACE" ifname "$IFACE"

echo "Lab setup complete!"
