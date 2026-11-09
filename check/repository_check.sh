#!/bin/bash
# repository_check.sh (RHCSA practice)
# An enabled repo must point at the EPEL 9 baseurl from the task, and dnf must
# be able to load it. (A repo installed by the epel-release package uses a
# metalink, not this baseurl, so it doesn't count.)

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

URL="https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64"

# Find enabled repo ids whose baseurl is the task URL (with or without a
# trailing slash). Parses /etc/yum.repos.d/*.repo directly so it works
# offline and ignores commented-out lines.
repo_id=$(sudo awk -v url="$URL" '
    function flush() { if (id != "" && enabled && match_url) print id }
    /^[[:space:]]*\[/ { flush(); id = $0; gsub(/[][[:space:]]/, "", id); enabled = 1; match_url = 0; next }
    /^[[:space:]]*enabled[[:space:]]*=/ { v = $0; sub(/^[^=]*=[[:space:]]*/, "", v); enabled = (v == "1" || tolower(v) == "true" || tolower(v) == "yes") }
    /^[[:space:]]*baseurl[[:space:]]*=/ { v = $0; sub(/^[^=]*=[[:space:]]*/, "", v); sub(/\/+[[:space:]]*$/, "", v); if (v == url) match_url = 1 }
    END { flush() }
' /etc/yum.repos.d/*.repo 2>/dev/null | head -n 1)

[[ -n "$repo_id" ]] || fail

# Prove dnf can actually use it.
sudo dnf -q makecache --repo "$repo_id" &>/dev/null || fail

pass
