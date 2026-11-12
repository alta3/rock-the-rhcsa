#!/bin/bash
# ssh_lab_keys_setup.sh (RH124 lab: Configure key-based authentication for SSH) - run on rhel-1
#
# - Creates a fresh throwaway user moe (password: flamingmoe) with no SSH keys.
# - Builds and starts a second, lab-only OpenSSH server that students harden
#   and break without any risk to the real one:
#     real sshd:  port 22,   /etc/ssh/sshd_config,     sshd.service      (NOT touched)
#     lab sshd:   port 2222, /etc/ssh/sshd_lab_config, sshd-lab.service  (created here)
#   It only lets moe (and root, so PermitRootLogin matters) in, and
#   PerSourcePenalties is off for it, so failed logins there never block anyone.
#   Port 2222 is labelled ssh_port_t for SELinux here, so the student doesn't have to.
#   firewalld is not touched (it isn't installed on these VMs; if it is running,
#   2222/tcp is opened, and ssh_lab_cleanup.sh closes it again).
#
# Re-running it starts the lab over. Undo everything with ssh_lab_cleanup.sh.
# Does not touch the real sshd, its config, or the student/root accounts.

USER_NAME=moe
USER_PASS=flamingmoe
PORT=2222
CFG=/etc/ssh/sshd_lab_config
DROPDIR=/etc/ssh/sshd_lab_config.d
UNIT=/etc/systemd/system/sshd-lab.service
die() { echo "SETUP FAILED: $*"; exit 1; }

# --- the throwaway user ---------------------------------------------------------
if id "$USER_NAME" &>/dev/null; then
    sudo loginctl terminate-user "$USER_NAME" &>/dev/null
    sleep 1
    sudo userdel -r "$USER_NAME" &>/dev/null
fi
sudo useradd "$USER_NAME" || die "could not create the user $USER_NAME"
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

# --- the lab sshd -----------------------------------------------------------------
sudo systemctl stop sshd-lab &>/dev/null
sudo systemctl reset-failed sshd-lab &>/dev/null

sudo tee "$CFG" >/dev/null <<'EOF'
# Lab-only OpenSSH server for the "Configure key-based authentication for SSH" lab.
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

# Lab only: these are the only users who may log in on port 2222.
AllowUsers moe root

# Lab only: failed logins on port 2222 never block anyone.
PerSourcePenalties no

Subsystem sftp /usr/libexec/openssh/sftp-server
EOF

sudo mkdir -p "$DROPDIR"
sudo rm -f "$DROPDIR"/*.conf
echo 'PasswordAuthentication yes' | sudo tee "$DROPDIR/50-cloud-init.conf" >/dev/null
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

# SELinux: sshd may only bind ports labelled ssh_port_t.
if ! sudo semanage port -l | grep -qE "^ssh_port_t +tcp +(.*[ ,])?$PORT(,|$)"; then
    sudo semanage port -a -t ssh_port_t -p tcp "$PORT" || die "could not label port $PORT for SELinux"
fi

# Firewall: only if firewalld happens to be running.
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd -q --add-port="$PORT/tcp"
fi

sudo sshd -t -f "$CFG" || die "the lab sshd config does not validate"
sudo systemctl start sshd-lab || die "could not start sshd-lab"

echo
echo "Lab user:  $USER_NAME / $USER_PASS"
echo "Lab sshd:  $CFG (port $PORT, service sshd-lab - running)"
echo
echo "Setup is complete. Begin the lab!"
