#!/bin/bash
# network_check.sh (RHCSA practice)
# ens4 profile: 192.168.50.100/24, gateway 192.168.50.1, DNS 8.8.8.8;
# static hostname millennium-falcon.
#
# Every check runs, and each failure says what was found vs. what was
# expected, so students can see exactly what is left to fix.


#The solution
#sudo nmcli con mod ens4 ipv4.method manual \
#  ipv4.addresses 192.168.50.100/24 \
#  ipv4.gateway 192.168.50.1 \
#  ipv4.dns 8.8.8.8
#sudo hostnamectl set-hostname millennium-falcon

HOST="millennium-falcon"
ADDR="192.168.50.100/24"
GW="192.168.50.1"
DNS="8.8.8.8"
CON="ens4"

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; RESET="\e[0m"
failures=0

ok()   { echo -e "  ${GREEN}[PASS]${RESET} $1"; }
bad()  { echo -e "  ${RED}[FAIL]${RESET} $1"; failures=$((failures + 1)); }
hint() { echo -e "         ${YELLOW}hint:${RESET} $1"; }

echo "Checking hostname and the '$CON' connection profile..."
echo

# --- Hostname (must be the STATIC hostname) --------------------------------
static_host=$(hostnamectl --static 2>/dev/null)
if [[ "$static_host" == "$HOST" ]]; then
  ok "Static hostname is '$HOST'"
else
  bad "Static hostname is '${static_host:-<empty>}', expected '$HOST'"
  hint "sudo hostnamectl set-hostname $HOST"
fi

# --- Does the ens4 profile exist? ------------------------------------------
if ! sudo nmcli -g connection.id connection show "$CON" >/dev/null 2>&1; then
  bad "No NetworkManager connection profile named '$CON' was found"
  hint "Run 'nmcli con show'. The grader only looks at a profile named '$CON'."
  hint "If it is missing, re-run the lab setup script (this resets '$CON')."
  echo
  echo -e "${RED}NO PASS - TRY AGAIN!${RESET} ($failures check(s) failed)"
  exit 1
fi

method=$(sudo nmcli -g ipv4.method connection show "$CON" 2>/dev/null)
addrs=$(sudo nmcli -g ipv4.addresses connection show "$CON" 2>/dev/null)
gw=$(sudo nmcli -g ipv4.gateway connection show "$CON" 2>/dev/null)
dns=$(sudo nmcli -g ipv4.dns connection show "$CON" 2>/dev/null)

# --- IP address (compare whole entries, prefix length included) ------------
if [[ ",${addrs// /}," == *",$ADDR,"* ]]; then
  ok "IP address is $ADDR"
else
  bad "IP address is '${addrs:-<not set>}', expected '$ADDR'"
  hint "Include the prefix length (/24). Without it NetworkManager stores /32."
  [[ "$method" != "manual" ]] && \
    hint "ipv4.method is '$method'. Set it to 'manual' so the address is used."
fi

# --- Gateway ----------------------------------------------------------------
if [[ "$gw" == "$GW" ]]; then
  ok "Gateway is $GW"
else
  bad "Gateway is '${gw:-<not set>}', expected '$GW'"
  hint "sudo nmcli con mod $CON ipv4.gateway $GW"
fi

# --- DNS --------------------------------------------------------------------
if [[ ",${dns// /}," == *",$DNS,"* ]]; then
  ok "DNS includes $DNS"
else
  bad "DNS is '${dns:-<not set>}', expected '$DNS'"
  hint "sudo nmcli con mod $CON ipv4.dns $DNS"
fi

# --- Result -----------------------------------------------------------------
echo
if (( failures == 0 )); then
  echo -e "${GREEN}SUCCESS!${RESET}"
  exit 0
else
  echo -e "${RED}NO PASS - TRY AGAIN!${RESET} ($failures check(s) failed)"
  echo "Tip: after fixing, run 'sudo nmcli con up $CON' if you want the changes applied now."
  exit 1
fi
