#!/bin/bash
# 10_tuned_profile_check.sh (RHCSA practice)
# The active tuned profile must be exactly the recommended one, with tuned
# running and enabled at boot.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

systemctl is-active --quiet tuned  || fail
systemctl is-enabled --quiet tuned || fail

# Run as root: without root, tuned skips virtualization-based recommendations.
recommended=$(sudo tuned-adm recommend 2>/dev/null | tail -n 1)
active=$(sudo tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p')

[[ -n "$recommended" ]]              || fail
[[ "$active" == "$recommended" ]]    || fail

pass
