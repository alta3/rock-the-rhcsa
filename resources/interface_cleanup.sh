#!/bin/bash
# interface_cleanup.sh (RH124 lab: Configure IP addresses and hostnames) - run on rhel-1 with sudo
# Undoes interface_setup.sh:
#   - deletes the practice connections (ens4, and rhcsa-nmtui from older versions of the lab)
#   - deletes the ens4 device
#   - if the setup had to switch NetworkManager on (the lab VMs ship with it masked),
#     stops, disables and masks it again and removes the setup's config file.
#     If NetworkManager was already running the network before the lab, it is left alone.
# Never touches eth0, /etc/resolv.conf or the hostname. Safe to run more than once.
IFACE="ens4"
LABCONF=/etc/NetworkManager/conf.d/90-rhcsa-lab-ens4-only.conf

if systemctl is-active --quiet NetworkManager; then
  for c in "$IFACE" rhcsa-nmtui; do
    if nmcli -t -f NAME con show | grep -qx "$c"; then
      sudo nmcli connection delete "$c" >/dev/null && echo "Removed connection $c"
    fi
  done
fi

if ip link show "$IFACE" >/dev/null 2>&1; then
  sudo ip link delete "$IFACE" && echo "Removed device $IFACE"
fi

if [[ -f "$LABCONF" ]]; then
  # NetworkManager was not in charge before the lab: put it back the way it was.
  # Stopping it does not touch eth0, because the config above kept it unmanaged.
  sudo systemctl disable --now NetworkManager NetworkManager-wait-online NetworkManager-dispatcher &>/dev/null
  sudo systemctl mask NetworkManager &>/dev/null
  sudo rm -f "$LABCONF"
  echo "NetworkManager stopped and masked again, as it was before the lab"
else
  echo "NetworkManager was running before the lab, so it was left running"
fi

if [[ "$(hostnamectl hostname)" != "rhel-1" ]]; then
  echo "Note: the hostname is still '$(hostnamectl hostname)'. Set it back with: sudo hostnamectl set-hostname rhel-1"
fi

echo "Cleanup is complete."
