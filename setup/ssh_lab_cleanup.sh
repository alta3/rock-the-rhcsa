#!/bin/bash
# ssh_lab_cleanup.sh (RH124 SSH labs) - run on rhel-1
# Undoes everything the SSH lab setup scripts did:
#   - removes the throwaway users apu, moe and lisa
#   - removes the lab-only sshd (sshd-lab.service, /etc/ssh/sshd_lab_config*)
#   - removes the SELinux ssh_port_t label for port 2222
#   - removes firewalld if ssh_lab_server_setup.sh installed it
#     (otherwise just closes 2222/tcp again)
# The real sshd (port 22) is never touched. Safe to run more than once.

PORT=2222
STATE=/var/lib/ssh_lab

for u in apu moe lisa; do
    if id "$u" &>/dev/null; then
        sudo loginctl terminate-user "$u" &>/dev/null
        sleep 1
        sudo userdel -r "$u" &>/dev/null && echo "Removed user $u"
    fi
done

if [[ -e /etc/systemd/system/sshd-lab.service ]]; then
    sudo systemctl disable --now sshd-lab &>/dev/null
    sudo rm -f /etc/systemd/system/sshd-lab.service
    sudo systemctl daemon-reload
    echo "Removed sshd-lab.service"
fi
sudo systemctl reset-failed sshd-lab &>/dev/null
sudo rm -rf /etc/ssh/sshd_lab_config /etc/ssh/sshd_lab_config.d

if sudo semanage port -l -C 2>/dev/null | grep -qE "^ssh_port_t +tcp +.*\b$PORT\b"; then
    sudo semanage port -d -t ssh_port_t -p tcp "$PORT" && echo "Removed SELinux label ssh_port_t from tcp/$PORT"
fi

if [[ -e "$STATE/installed_firewalld" ]]; then
    sudo systemctl disable --now firewalld &>/dev/null
    sudo dnf remove -y -q firewalld &>/dev/null
    sudo rm -rf /etc/firewalld
    echo "Removed firewalld (the SSH lab installed it)"
elif rpm -q firewalld &>/dev/null && systemctl is-active --quiet firewalld; then
    sudo firewall-cmd -q --permanent --remove-port="$PORT/tcp" &>/dev/null
    sudo firewall-cmd -q --remove-port="$PORT/tcp" &>/dev/null
fi
sudo rm -rf "$STATE"

echo "Cleanup is complete."
