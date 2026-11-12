#!/bin/bash
# ssh_secure_cleanup.sh (RHCSA practice) - run on rhel-2 as student
# Undoes ssh_secure_setup.sh: removes bart (rhel-2), skinner and the practice
# sshd-exam server (rhel-1), and the port 2022 SELinux label / firewall rule if
# setup added them. The real sshd is never touched. Safe to run more than once.

[[ $EUID -ne 0 ]] || { echo "Run this as student, not as root (no sudo)."; exit 1; }

R1=$(getent ahostsv4 rhel-1 | awk 'NR==1{print $1}')

if id bart &>/dev/null; then
    sudo loginctl terminate-user bart &>/dev/null
    sleep 1
    sudo userdel -r bart &>/dev/null && echo "Removed user bart (rhel-2)"
fi

[[ -n "$R1" ]] || { echo "Can't resolve rhel-1 - run this on rhel-2."; exit 1; }
ssh -o BatchMode=yes -o ConnectTimeout=15 "$R1" 'sudo bash -s' <<'REMOTE'
PORT=2022
ST=/var/lib/ssh_secure
if id skinner &>/dev/null; then
    loginctl terminate-user skinner &>/dev/null
    sleep 1
    userdel -r skinner &>/dev/null && echo "Removed user skinner (rhel-1)"
fi
if [[ -e /etc/systemd/system/sshd-exam.service ]]; then
    systemctl disable --now sshd-exam </dev/null &>/dev/null
    rm -f /etc/systemd/system/sshd-exam.service
    systemctl daemon-reload
    echo "Removed sshd-exam.service (rhel-1)"
fi
systemctl reset-failed sshd-exam </dev/null &>/dev/null
rm -rf /etc/ssh/sshd_exam_config /etc/ssh/sshd_exam_config.d
if [[ -e "$ST/added_label" ]]; then
    semanage port -d -t ssh_port_t -p tcp "$PORT" </dev/null &>/dev/null && echo "Removed SELinux label ssh_port_t from tcp/$PORT (rhel-1)"
fi
if [[ -e "$ST/added_port" ]] && systemctl is-active --quiet firewalld; then
    firewall-cmd -q --permanent --remove-port="$PORT/tcp" && firewall-cmd -q --reload
fi
rm -rf "$ST"
REMOTE

echo "Cleanup is complete."
