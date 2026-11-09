#!/bin/bash
# ntp_check.sh (RHCSA practice)
# chrony must be configured (persistently) to use time.cloudflare.com, and
# chronyd must be running with it, and enabled at boot.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

SERVER="time.cloudflare.com"

# 1. In the config (survives a reboot); comments don't count
shopt -s nullglob
grep -Eqs "^[[:space:]]*(server|pool)[[:space:]]+${SERVER//./\\.}([[:space:]]|$)" \
    /etc/chrony.conf /etc/chrony.d/*.conf || fail

# 2. chronyd running and enabled
systemctl is-active --quiet chronyd  || fail
systemctl is-enabled --quiet chronyd || fail

# 3. chronyd is actually using it. -N prints the names from the config,
#    so this doesn't depend on reverse DNS.
chronyc -N sources 2>/dev/null | grep -q "$SERVER" || fail

pass
