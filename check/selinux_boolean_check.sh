#!/bin/bash
# selinux_boolean_check.sh (RHCSA practice)
# logrotate_read_inside_containers must be on now AND persistently (setsebool -P).

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

BOOL=logrotate_read_inside_containers

if ! command -v semanage &>/dev/null; then
    sudo dnf install -y -q policycoreutils-python-utils &>/dev/null
    if ! command -v semanage &>/dev/null; then
        echo "This check needs semanage. Install it with: sudo dnf install -y policycoreutils-python-utils"
        exit 2
    fi
fi

# semanage boolean -l prints: name (current , persistent) description
line=$(sudo semanage boolean -l 2>/dev/null | awk -v b="$BOOL" '$1 == b')
[[ -n "$line" ]] || fail

read -r current persistent < <(sed -E 's/^[^(]*\(([a-z]+)[[:space:]]*,[[:space:]]*([a-z]+)\).*/\1 \2/' <<<"$line")

[[ "$current" == "on" ]]    || fail
[[ "$persistent" == "on" ]] || fail

pass
