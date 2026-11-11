#!/bin/bash
# autofs_docs_setup.sh (RHCSA practice)
# Builds a local NFS server that exports /exports/docs read-only, so the
# student only has to configure the autofs client side.
# Uses /etc/exports.d (does not edit /etc/exports) and does not touch
# /etc/hosts or the firewall: the client mounts from localhost.

EXPORT_DIR=/exports/docs
EXPORT_FILE=/etc/exports.d/rhcsa-docs.exports

if ! rpm -q nfs-utils &>/dev/null; then
    if ! sudo dnf install -y -q nfs-utils; then
        echo "Could not install nfs-utils - see the error above."
        exit 1
    fi
fi

sudo mkdir -p "$EXPORT_DIR"
echo "Springfield Nuclear Power Plant: safety manual, page 1 of 1" \
    | sudo tee "$EXPORT_DIR/manual.txt" >/dev/null
sudo chmod 644 "$EXPORT_DIR/manual.txt"

echo "$EXPORT_DIR *(ro,sync)" | sudo tee "$EXPORT_FILE" >/dev/null

sudo systemctl enable --now nfs-server &>/dev/null
sudo exportfs -ra

if ! showmount -e localhost 2>/dev/null | grep -q "^$EXPORT_DIR "; then
    echo "The NFS export did not come up - ask your instructor."
    exit 1
fi

echo "Setup is complete. Begin your task!"
