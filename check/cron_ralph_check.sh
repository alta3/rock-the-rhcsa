#!/bin/bash
# cron_ralph_check.sh (RHCSA practice)
# ralph's own crontab must hold a job that runs at 07:15 every weekday
# (Mon-Fri) and appends the output of date to /home/ralph/bus.log.
# crond must be running and enabled.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

LOG=/home/ralph/bus.log

id ralph &>/dev/null                || fail
systemctl is-active --quiet crond   || fail
systemctl is-enabled --quiet crond  || fail

# --- Find a job line with the right schedule.
#     Accepted weekday forms: 1-5, mon-fri, 1,2,3,4,5 (any case).
job_cmd=""
while read -r min hour dom mon dow cmd; do
    [[ -z "$min" || "$min" == \#* || "$min" == *=* ]] && continue
    [[ "$min" =~ ^0?15$ && "$hour" =~ ^0?7$ ]]  || continue
    [[ "$dom" == "*" && "$mon" == "*" ]]        || continue
    case "${dow,,}" in
        1-5|mon-fri|1,2,3,4,5) ;;
        *) continue ;;
    esac
    job_cmd="$cmd"
    break
done < <(sudo crontab -l -u ralph 2>/dev/null)

[[ -n "$job_cmd" ]] || fail

# --- The command really appends a date line to the log when ralph runs it.
#     Run it the way cron would (sh, as ralph, from his home) TWICE: an
#     overwrite (>) instead of an append (>>) would still leave one line on
#     an empty log. Then put the log back exactly as it was.
backup=$(mktemp)
had_log=0
if sudo test -e "$LOG"; then had_log=1; sudo cp -p "$LOG" "$backup"; fi
before=$(sudo sh -c "wc -l < '$LOG'" 2>/dev/null || echo 0)

sudo -u ralph -H sh -c "cd ~ && $job_cmd" &>/dev/null
sudo -u ralph -H sh -c "cd ~ && $job_cmd" &>/dev/null

after=$(sudo sh -c "wc -l < '$LOG'" 2>/dev/null || echo 0)
last=$(sudo tail -n 1 "$LOG" 2>/dev/null)
owner=$(sudo stat -c %U "$LOG" 2>/dev/null)

if (( had_log )); then sudo cp -p "$backup" "$LOG"; else sudo rm -f "$LOG"; fi
sudo rm -f "$backup"

(( after == before + 2 ))                    || fail
[[ "$last" == *"$(date +%Y)"* ]]             || fail
[[ "$owner" == "ralph" ]]                    || fail

pass
