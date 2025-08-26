#!/bin/bash
set -euo pipefail

HOST="millennium-falcon"
IP="192.168.50.100"
GW="192.168.50.1"
DNS="8.8.8.8"

fail(){ echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"; exit 1; }

# Hostname check
[[ "$(hostnamectl --static)" == "$HOST" ]] || fail

# Grab settings from NM profile
PROFILE=$(sudo nmcli -g ipv4.addresses,ipv4.gateway,ipv4.dns con show ens4 2>/dev/null || true)

[[ "$PROFILE" == *"$IP"* ]]  || fail
[[ "$PROFILE" == *"$GW"* ]]  || fail
[[ "$PROFILE" == *"$DNS"* ]] || fail

echo -e "\e[32mSUCCESS!\e[0m"
