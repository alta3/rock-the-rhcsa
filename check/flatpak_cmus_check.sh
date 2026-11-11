#!/bin/bash
# flatpak_cmus_check.sh (RHCSA practice)
# A system-wide remote named flathub must exist, and the cmus application
# (io.github.cmus.cmus) must be installed system-wide from it.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

APP=io.github.cmus.cmus

command -v flatpak &>/dev/null || fail

# The system remote must be called flathub, point at Flathub, and be enabled.
remote=$(flatpak remotes --system --show-disabled --columns=name,url,options 2>/dev/null | awk -F'\t' '$1=="flathub"')
[[ -n "$remote" ]]                  || fail
[[ "$remote" == *flathub.org* ]]    || fail
[[ "$remote" != *disabled* ]]       || fail

# Installed system-wide (not --user), and it came from flathub.
flatpak list --system --app --columns=application,origin 2>/dev/null \
    | grep -qxP "${APP//./\\.}\tflathub" || fail

pass
