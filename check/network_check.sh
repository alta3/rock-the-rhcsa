#!/bin/bash
# network_check.sh (RHCSA practice)
# ens4 profile: 192.168.50.100/24, gateway 192.168.50.1, DNS 8.8.8.8;
# static hostname millennium-falcon.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

HOST="millennium-falcon"
ADDR="192.168.50.100/24"
GW="192.168.50.1"
DNS="8.8.8.8"

[[ "$(hostnamectl --static)" == "$HOST" ]] || fail

# Compare each field on its own (a substring test would let the gateway
# match inside the IP address).
addrs=$(sudo nmcli -g ipv4.addresses connection show ens4 2>/dev/null)   || fail
gw=$(sudo nmcli -g ipv4.gateway connection show ens4 2>/dev/null)        || fail
dns=$(sudo nmcli -g ipv4.dns connection show ens4 2>/dev/null)           || fail

[[ ",${addrs// /}," == *",$ADDR,"* ]] || fail
[[ "$gw" == "$GW" ]]                   || fail
[[ ",${dns// /}," == *",$DNS,"* ]]     || fail

pass
