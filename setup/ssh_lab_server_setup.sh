#!/bin/bash
# ssh_lab_server_setup.sh (RH124 lab: Configure the OpenSSH server) - run on rhel-1
#
# Builds a SECOND, lab-only OpenSSH server that students can reconfigure and
# break without any risk to the real one:
#   - real sshd:  port 22,   /etc/ssh/sshd_config,     sshd.service      (NOT touched)
#   - lab sshd:   port 2222, /etc/ssh/sshd_lab_config, sshd-lab.service  (created here)
# The lab sshd only lets the throwaway user lisa (password: saxophone) in, and
# PerSourcePenalties is off for it, so failed logins there never block anyone.
#
# It also makes sure firewalld is installed and running, with ssh (port 22)
# allowed, so the "open the new port in the firewall" step is real. If this
# script installed firewalld, ssh_lab_cleanup.sh removes it again.
#
# Starting state it leaves: sshd-lab NOT running, port 2222 NOT labelled for
# SELinux, and NOT open in the firewall. That's for the student to fix.
# Re-running it starts the lab over. Undo everything with ssh_lab_cleanup.sh.

USER_NAME=lisa
USER_PASS=saxophone
PORT=2222
CFG=/etc/ssh/sshd_lab_config
DROPDIR=/etc/ssh/sshd_lab_config.d
UNIT=/etc/systemd/system/sshd-lab.service
STATE=/var/lib/ssh_lab
die() { echo "SETUP FAILED: $*"; exit 1; }

sudo mkdir -p "$STATE"

# --- the throwaway user -----------------------------------------------------
if id "$USER_NAME" &>/dev/null; then
    sudo loginctl terminate-user "$USER_NAME" &>/dev/null
    sleep 1
    sudo userdel -r "$USER_NAME" &>/dev/null
fi
sudo useradd "$USER_NAME" || die "could not create the user $USER_NAME"
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

# --- the lab sshd (config, drop-in, unit) -------------------------------------
sudo systemctl stop sshd-lab &>/dev/null
sudo systemctl reset-failed sshd-lab &>/dev/null

sudo tee "$CFG" >/dev/null <<'EOF'
# Lab-only OpenSSH server for the "Configure the OpenSSH server" lab.
# It is run by sshd-lab.service and listens on port 2222.
# The REAL sshd (port 22) reads /etc/ssh/sshd_config and is NOT affected by this file.
#
# Like the real /etc/ssh/sshd_config, this file reads its drop-in directory first.
# sshd uses the FIRST value it finds for each setting.
Include /etc/ssh/sshd_lab_config.d/*.conf

Port 2222
PidFile /run/sshd-lab.pid

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

SyslogFacility AUTHPRIV

# Authentication:
#PermitRootLogin prohibit-password
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes

# Lab only: lisa is the only user who may log in on port 2222.
AllowUsers lisa

# Lab only: failed logins on port 2222 never block anyone.
PerSourcePenalties no

Subsystem sftp /usr/libexec/openssh/sftp-server
EOF

sudo mkdir -p "$DROPDIR"
sudo tee "$DROPDIR/50-cloud-init.conf" >/dev/null <<'EOF'
PasswordAuthentication yes
EOF
sudo chmod 600 "$CFG" "$DROPDIR/50-cloud-init.conf"

sudo tee "$UNIT" >/dev/null <<'EOF'
[Unit]
Description=Lab-only OpenSSH server (port 2222) - safe to break
After=network.target sshd-keygen.target

[Service]
Type=notify
# Unlike the real sshd.service, this unit checks the config before it starts
# or reloads, so a typo can't take the lab server down on reload.
ExecStartPre=/usr/sbin/sshd -t -f /etc/ssh/sshd_lab_config
ExecStart=/usr/sbin/sshd -D -f /etc/ssh/sshd_lab_config
ExecReload=/usr/sbin/sshd -t -f /etc/ssh/sshd_lab_config
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=no
EOF
sudo systemctl daemon-reload
sudo sshd -t -f "$CFG" || die "the lab sshd config does not validate"

# --- SELinux: port 2222 starts unlabelled -------------------------------------
if sudo semanage port -l -C | grep -qE "^ssh_port_t +tcp +.*\b$PORT\b"; then
    sudo semanage port -d -t ssh_port_t -p tcp "$PORT"
fi

# --- firewalld: installed, running, ssh allowed, 2222 closed --------------------
if ! rpm -q firewalld &>/dev/null; then
    echo "Installing firewalld..."
    sudo dnf install -y -q firewalld || die "could not install firewalld"
    sudo touch "$STATE/installed_firewalld"
fi

# Which zone does eth0 traffic land in? Its own zone if it has one, else the default.
if systemctl is-active --quiet firewalld; then
    FWC="sudo firewall-cmd"
else
    FWC="sudo firewall-offline-cmd"
fi
ZONE=$($FWC --get-zone-of-interface=eth0 2>/dev/null)
[[ -n "$ZONE" && "$ZONE" != "no zone" ]] || ZONE=$($FWC --get-default-zone)
[[ -n "$ZONE" ]] || die "could not work out the firewalld zone"

# Make sure ssh (port 22) is allowed BEFORE firewalld is started.
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --permanent --zone="$ZONE" --query-service=ssh &>/dev/null ||
        sudo firewall-cmd --permanent --zone="$ZONE" --add-service=ssh >/dev/null
    sudo firewall-cmd --permanent --zone="$ZONE" --remove-port="$PORT/tcp" &>/dev/null
    sudo firewall-cmd --reload >/dev/null
else
    sudo firewall-offline-cmd --zone="$ZONE" --query-service=ssh &>/dev/null ||
        sudo firewall-offline-cmd --zone="$ZONE" --add-service=ssh >/dev/null
    sudo firewall-offline-cmd --zone="$ZONE" --remove-port="$PORT/tcp" &>/dev/null
    sudo firewall-offline-cmd --zone="$ZONE" --query-service=ssh &>/dev/null ||
        die "ssh is not allowed in firewalld zone $ZONE - not starting firewalld"
    sudo systemctl enable --now firewalld &>/dev/null || die "could not start firewalld"
fi

# Final safety check: if ssh isn't allowed now, turn the firewall back off.
if ! sudo firewall-cmd --zone="$ZONE" --query-service=ssh &>/dev/null; then
    sudo systemctl stop firewalld
    die "ssh was not allowed by firewalld, so firewalld was stopped again"
fi

echo
echo "Lab sshd:  $CFG (port $PORT, service sshd-lab - not started yet)"
echo "Lab user:  $USER_NAME / $USER_PASS"
echo "Firewall:  firewalld running, zone $ZONE allows ssh; port $PORT/tcp is closed"
echo
echo "Setup is complete. Begin the lab!"
