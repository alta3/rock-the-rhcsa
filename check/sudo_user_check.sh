#!/bin/bash
# sudo_user_check.sh (RHCSA practice)
# neo may run "systemctl restart httpd" with sudo and no password, and
# nothing more. Works whether the rule is in /etc/sudoers or /etc/sudoers.d/.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

id neo &>/dev/null || fail

# A sudoers syntax error breaks sudo for everyone.
sudo visudo -c &>/dev/null || fail

SYSTEMCTL=$(command -v systemctl)

# sudo itself decides whether neo is allowed to run the command.
sudo -l -U neo "$SYSTEMCTL" restart httpd &>/dev/null || fail

# ...and without a password.
sudo -l -U neo 2>/dev/null | grep -Eq 'NOPASSWD:.*systemctl restart httpd' || fail

# ...and neo must not have been given unrelated commands (e.g. ALL).
sudo -l -U neo /usr/bin/id &>/dev/null && fail
sudo -l -U neo "$SYSTEMCTL" stop httpd &>/dev/null && fail

pass
