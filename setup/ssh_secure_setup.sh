#!/bin/bash
# ssh_secure_setup.sh (RHCSA practice) - run on rhel-2 as student
#
# rhel-2: creates the throwaway user bart (password: cowabunga), with no SSH keys.
# rhel-1: creates the throwaway user skinner (password: superintendent), with no keys,
#         and a practice OpenSSH server "sshd-exam" on port 2022:
#           config   /etc/ssh/sshd_exam_config   (+ drop-ins in /etc/ssh/sshd_exam_config.d/)
#           service  sshd-exam.service           (started, NOT enabled)
#         It starts out allowing root and password logins, like an unhardened server.
#         Port 2022 is labelled ssh_port_t for SELinux (and opened in firewalld if
#         firewalld happens to be running) so the student doesn't have to.
#
# The real sshd (port 22), its config, and the student/root accounts are not touched.
# Undo everything with ssh_secure_cleanup.sh. Re-running this starts the task over.

die() { echo "SETUP FAILED: $*"; exit 1; }

# As root, "ssh rhel-1" below would be a failed login (root has no key there).
[[ $EUID -ne 0 ]] || die "run this as student, not as root (no sudo)"

# rhel-1 by address: student's ~/.ssh/config skips host-key prompts for 10.*
R1=$(getent ahostsv4 rhel-1 | awk 'NR==1{print $1}')
[[ -n "$R1" ]] || die "can't resolve rhel-1 - run this on rhel-2"
[[ "$(hostname -s)" == rhel-2 ]] || die "run this on rhel-2"

# --- rhel-2: bart ---------------------------------------------------------------
if id bart &>/dev/null; then
    sudo loginctl terminate-user bart &>/dev/null
    sleep 1
    sudo userdel -r bart &>/dev/null
fi
sudo useradd bart || die "could not create bart"
echo 'bart:cowabunga' | sudo chpasswd

# --- rhel-1: skinner + practice sshd --------------------------------------------
ssh -o BatchMode=yes -o ConnectTimeout=15 "$R1" 'sudo bash -s' <<'REMOTE' || die "the rhel-1 part failed (see above)"
set -u
PORT=2022
CFG=/etc/ssh/sshd_exam_config
DD=/etc/ssh/sshd_exam_config.d
UNIT=/etc/systemd/system/sshd-exam.service
ST=/var/lib/ssh_secure
mkdir -p "$ST"

if id skinner &>/dev/null; then
    loginctl terminate-user skinner &>/dev/null
    sleep 1
    userdel -r skinner &>/dev/null
fi
useradd skinner || exit 1
echo 'skinner:superintendent' | chpasswd

systemctl disable --now sshd-exam </dev/null &>/dev/null
systemctl reset-failed sshd-exam </dev/null &>/dev/null

cat > "$CFG" <<'EOF'
# Practice OpenSSH server for the "SSH: Passwordless Login and a Hardened Server" task.
# Run by sshd-exam.service on port 2022. Treat this file like /etc/ssh/sshd_config.
# The REAL sshd (port 22) does not read this file.
#
# Like /etc/ssh/sshd_config, the drop-in directory is read first, and sshd uses
# the FIRST value it finds for each setting.
Include /etc/ssh/sshd_exam_config.d/*.conf

Port 2022
PidFile /run/sshd-exam.pid

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

SyslogFacility AUTHPRIV

# Authentication:
PermitRootLogin yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

#PasswordAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes

# Practice server only: these are the only users who may log in on port 2022.
AllowUsers skinner root

# Practice server only: failed logins on port 2022 never block anyone.
PerSourcePenalties no

Subsystem sftp /usr/libexec/openssh/sftp-server
EOF
mkdir -p "$DD"
echo 'PasswordAuthentication yes' > "$DD/50-cloud-init.conf"
chmod 600 "$CFG" "$DD/50-cloud-init.conf"

cat > "$UNIT" <<'EOF'
[Unit]
Description=Practice OpenSSH server (port 2022) for the SSH challenge
After=network.target sshd-keygen.target

[Service]
Type=notify
ExecStartPre=/usr/sbin/sshd -t -f /etc/ssh/sshd_exam_config
ExecStart=/usr/sbin/sshd -D -f /etc/ssh/sshd_exam_config
ExecReload=/usr/sbin/sshd -t -f /etc/ssh/sshd_exam_config
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=no

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

# SELinux: sshd may only bind ports labelled ssh_port_t.
if ! semanage port -l </dev/null | grep -qE "^ssh_port_t +tcp +(.*[ ,])?$PORT(,|$)"; then
    semanage port -a -t ssh_port_t -p tcp "$PORT" </dev/null || exit 1
    touch "$ST/added_label"
fi

# Firewall: only if firewalld is running (it normally isn't on these VMs).
if systemctl is-active --quiet firewalld; then
    if ! firewall-cmd -q --permanent --query-port="$PORT/tcp"; then
        firewall-cmd -q --permanent --add-port="$PORT/tcp" && touch "$ST/added_port"
    fi
    firewall-cmd -q --reload
fi

sshd -t -f "$CFG" || exit 1
systemctl start sshd-exam </dev/null || exit 1
REMOTE

echo "Setup is complete. Begin your task!"
