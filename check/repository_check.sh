#!/bin/bash
# repository_check.sh (RHCSA practice)
# An enabled repo must point at the EPEL 9 baseurl from the task, and dnf must
# be able to load it. (A repo installed by the epel-release package uses a
# metalink, not this baseurl, so it doesn't count.)

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

URL="https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64"

# Values dnf substitutes for $releasever and $basearch, so a hand-written
# repo file using those variables is judged the same as a literal URL.
REL=$(rpm -E %rhel 2>/dev/null); [[ "$REL" =~ ^[0-9]+$ ]] || REL=9
ARCH=$(uname -m)

# Find enabled repo ids whose baseurl is the task URL (with or without a
# trailing slash). Parses /etc/yum.repos.d/*.repo directly so it works
# offline and ignores commented-out lines. Handles trailing whitespace,
# $releasever/$basearch, and baseurl lists with several URLs.
repo_id=$(sudo awk -v url="$URL" -v rel="$REL" -v arch="$ARCH" '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function val(line) { sub(/^[^=]*=/, "", line); return trim(line) }
    function flush() { if (id != "" && enabled && match_url) print id; id = "" }
    FNR == 1 { flush() }
    /^[[:space:]]*\[/ { flush(); id = $0; gsub(/[][[:space:]]/, "", id); enabled = 1; match_url = 0; next }
    /^[[:space:]]*enabled[[:space:]]*=/ { v = tolower(val($0)); enabled = (v == "1" || v == "true" || v == "yes") }
    /^[[:space:]]*baseurl[[:space:]]*=/ {
        n = split(val($0), urls, /[[:space:],]+/)
        for (i = 1; i <= n; i++) {
            u = urls[i]
            gsub(/\$\{basearch\}|\$basearch/, arch, u)
            gsub(/\$\{releasever\}|\$releasever/, rel, u)
            sub(/\/+$/, "", u)
            if (u == url) match_url = 1
        }
    }
    END { flush() }
' /etc/yum.repos.d/*.repo 2>/dev/null | head -n 1)

if [[ -z "$repo_id" ]]; then
  if rpm -q epel-release &>/dev/null; then
    echo "Note: EPEL from the epel-release package uses a metalink and doesn't count."
    echo "Add the repository by the URL given in the task."
  fi
  fail
fi

# Prove dnf can actually use it.
sudo dnf -q makecache --repo "$repo_id" &>/dev/null || fail

pass
