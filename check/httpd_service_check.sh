#!/bin/bash
# httpd_service_check.sh (RHCSA practice)
# httpd must be installed, running, and enabled at boot.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

rpm -q httpd &>/dev/null                   || fail
systemctl is-active --quiet httpd          || fail
systemctl is-enabled --quiet httpd         || fail

pass
