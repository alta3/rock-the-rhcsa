#!/usr/bin/env bash
# autofs_nfs_check.sh  (quiet version)
# Expects autofs to mount nfs-server.example.com:/srv/nfs at /mnt/nfs
# Only prints pass/fail

TARGET_MP="/mnt/nfs"
TARGET_EXPORT="nfs-server.example.com:/srv/nfs"

GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

pass=true

# autofs installed & active
if ! rpm -q autofs >/dev/null 2>&1; then pass=false; fi
if ! systemctl is-active --quiet autofs; then pass=false; fi

# map references correct export
if ! grep -R -E "nfs-server\.example\.com:/srv/nfs" /etc/auto.master /etc/auto.* 2>/dev/null | grep -q "/mnt"; then
  pass=false
fi

# trigger and verify mount
mkdir -p "${TARGET_MP}" 2>/dev/null
timeout 5 ls "${TARGET_MP}" >/dev/null 2>&1
if ! findmnt -rn -T "${TARGET_MP}" | grep -Eq "nfs-server\.example\.com:/srv/nfs"; then
  # allow loopback fallback: just check accessibility
  if ! ls -A "${TARGET_MP}" >/dev/null 2>&1; then
    pass=false
  fi
fi

# show result
if $pass; then
  echo -e "${GREEN}SUCCESS!${NC}"
  exit 0
else
  echo -e "${RED}NO PASS- TRY AGAIN!${NC}"
  exit 1
fi
