#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# autofs_nfs_setup.sh
# Prepares a single-VM lab for an Autofs + NFS RHCSA-style task
# - Creates /srv/nfs and exports it
# - Ensures nfs-server is running
# - Maps nfs-server.example.com -> localhost in /etc/hosts
# - Opens firewall services if firewalld is running
# NOTE: This script intentionally does NOT configure autofs.
#       Students will do that as part of the task.
# ------------------------------------------------------------

say() { printf "\n[SETUP] %s\n" "$*"; }

# Basic sanity: we rely on sudo. Fail fast if it's not available.
if ! command -v sudo >/dev/null 2>&1; then
  echo "This script requires 'sudo' but it was not found. Aborting." >&2
  exit 1
fi

# 1) Packages
say "Installing required packages for NFS server..."
sudo dnf install -y nfs-utils >/dev/null

# 2) Ensure NFS directories and content
say "Creating export directory and a test file..."
sudo mkdir -p /srv/nfs
if [[ ! -f /srv/nfs/welcome.txt ]]; then
  echo "Welcome to the RHCSA autofs exam lab." | sudo tee /srv/nfs/welcome.txt >/dev/null
fi

# 3) Configure /etc/exports idempotently
say "Configuring /etc/exports for /srv/nfs..."
# Remove any existing /srv/nfs lines to avoid duplicates, then add the desired one
if grep -qE '^[[:space:]]*/srv/nfs[[:space:]]' /etc/exports 2>/dev/null; then
  sudo sed -i '\|^/srv/nfs |d' /etc/exports || true
  sudo sed -i '\|^/srv/nfs\t|d' /etc/exports || true
  sudo sed -i '\|^/srv/nfs$|d' /etc/exports || true
fi
# Add our export rule
echo "/srv/nfs *(rw,sync,no_root_squash)" | sudo tee -a /etc/exports >/dev/null

# 4) Enable and start NFS services
say "Enabling and starting nfs-server..."
sudo systemctl enable --now nfs-server

# 5) Map exam-style hostname to localhost (both IPv4 and IPv6)
say "Mapping nfs-server.example.com to localhost in /etc/hosts..."
if ! grep -qE '(^|\s)nfs-server\.example\.com(\s|$)' /etc/hosts; then
  echo "127.0.0.1 nfs-server.example.com" | sudo tee -a /etc/hosts >/dev/null
  echo "::1 nfs-server.example.com"      | sudo tee -a /etc/hosts >/dev/null
fi

# 6) Open firewall services if firewalld is active (harmless if not running)
if systemctl is-active --quiet firewalld; then
  say "Configuring firewalld (nfs, mountd, rpc-bind)..."
  sudo firewall-cmd --permanent --add-service=nfs >/dev/null || true
  sudo firewall-cmd --permanent --add-service=mountd >/dev/null || true
  sudo firewall-cmd --permanent --add-service=rpc-bind >/dev/null || true
  sudo firewall-cmd --reload >/dev/null || true
else
  say "firewalld not active; skipping firewall configuration."
fi

# 7) Reload NFS exports
say "Reloading NFS exports..."
sudo exportfs -ra

# 8) (Optional) Create the target mountpoint path students will use
#    Autofs direct maps can mount over this path; having it present avoids confusion.
say "Ensuring /mnt/nfs exists for the task..."
sudo mkdir -p /mnt/nfs

# 9) Quick sanity check (non-fatal)
say "Verifying export visibility via showmount..."
if command -v showmount >/dev/null 2>&1; then
  showmount -e nfs-server.example.com || true
else
  say "showmount not available (part of nfs-utils). Skipping."
fi

say "Setup complete. Students can now configure autofs to mount nfs-server.example.com:/srv/nfs at /mnt/nfs."
