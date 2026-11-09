#!/bin/bash
# 09_cron_renice_check.sh (RHCSA practice)
# The crond daemon must have a nice value of 10.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# crond forks child crond processes while running jobs; the oldest one is
# the daemon itself.
cron_pid=$(pgrep -o -x crond)
[[ -n "$cron_pid" ]] || fail

nice_value=$(ps -o ni= -p "$cron_pid" | tr -d ' ')
[[ "$nice_value" == "10" ]] || fail

pass
