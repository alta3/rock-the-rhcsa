#!/bin/bash
# password_policy_check.sh (RHCSA practice)
# PASS_MAX_DAYS 90 in /etc/login.defs, and pwquality minlen = 8.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# Last uncommented PASS_MAX_DAYS wins.
max_days=$(awk '$1 == "PASS_MAX_DAYS" { v = $2 } END { print v }' /etc/login.defs)

# pwquality reads pwquality.conf, then pwquality.conf.d/*.conf in sorted
# order; a later setting overrides an earlier one (man pwquality.conf).
shopt -s nullglob
conf_files=(/etc/security/pwquality.conf)
dropins=(/etc/security/pwquality.conf.d/*.conf)
conf_files+=($(printf '%s\n' "${dropins[@]}" | LC_ALL=C sort))
min_len=$(cat "${conf_files[@]}" 2>/dev/null \
  | sed -nE 's/^[[:space:]]*minlen[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*$/\1/p' \
  | tail -n 1)

[[ "$max_days" == "90" ]] || fail
[[ "$min_len" == "8" ]]   || fail

pass
