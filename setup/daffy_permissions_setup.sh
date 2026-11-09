#!/bin/bash
# daffy_permissions_setup.sh (RHCSA practice)

# Ensure the user "daffy" exists
if ! id "daffy" &>/dev/null; then
    echo "Creating user daffy..."
    sudo useradd daffy
fi

# Ensure home directory exists
sudo mkdir -p /home/daffy
sudo chown daffy:daffy /home/daffy

# Intentionally wrong umask (002) in both files; the student must fix both.
# Remove any umask lines first so re-running setup doesn't stack them up.
for f in /home/daffy/.bashrc /home/daffy/.bash_profile; do
    sudo touch "$f"
    sudo sed -i '/^[[:space:]]*umask[[:space:]]/d' "$f"
    echo "umask 002" | sudo tee -a "$f" > /dev/null
    sudo chown daffy:daffy "$f"
done

echo "Setup complete!"
