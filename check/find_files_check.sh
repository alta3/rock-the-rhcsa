#!/bin/bash
# find_files_check.sh (RHCSA practice)
# /root/findresults must contain a copy of every regular file owned by frank
# (and nothing else).

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

DIR="/root/findresults"

id frank &>/dev/null || fail
sudo test -d "$DIR" || fail

# What frank owns right now (skip /proc and the results directory itself).
expected=$(sudo find / \( -path /proc -o -path "$DIR" \) -prune -o \
             -user frank -type f -printf '%f\n' 2>/dev/null | LC_ALL=C sort)
actual=$(sudo find "$DIR" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | LC_ALL=C sort)

[[ -n "$expected" ]]             || fail
[[ "$expected" == "$actual" ]]   || fail

pass
