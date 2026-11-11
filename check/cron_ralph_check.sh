#!/bin/bash
# cron_ralph_check.sh (RHCSA practice)
# A cron job that runs AS ralph at 07:15 every weekday (Mon-Fri) must
# append the output of date to /home/ralph/bus.log. crond must be running
# and enabled. The job may be in ralph's crontab (crontab -u ralph), or in
# /etc/crontab or /etc/cron.d/* with ralph in the user field.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

LOG=/home/ralph/bus.log

id ralph &>/dev/null                || fail
systemctl is-active --quiet crond   || fail
systemctl is-enabled --quiet crond  || fail

# Right schedule? minute 15, hour 7, any day of month, any month, Mon-Fri.
schedule_ok() {
    local min=$1 hour=$2 dom=$3 mon=$4 dow=${5,,}
    [[ "$min" =~ ^0?15$ && "$hour" =~ ^0?7$ ]] || return 1
    [[ "$dom" == "*" && "$mon" == "*" ]]       || return 1
    case "$dow" in
        1-5|mon-fri|1,2,3,4,5|mon,tue,wed,thu,fri) return 0 ;;
    esac
    return 1
}

job_cmd=""
job_shell=/bin/sh

# 1) ralph's own crontab: min hour dom mon dow command
shell=/bin/sh
while read -r min hour dom mon dow cmd; do
    [[ "$min" == SHELL=* ]] && { shell=${min#SHELL=}; continue; }
    [[ -z "$min" || "$min" == \#* || "$min" == *=* ]] && continue
    if schedule_ok "$min" "$hour" "$dom" "$mon" "$dow"; then
        job_cmd=$cmd; job_shell=$shell; break
    fi
done < <(sudo crontab -l -u ralph 2>/dev/null)

# 2) System crontabs: min hour dom mon dow user command
if [[ -z "$job_cmd" ]]; then
    for f in /etc/crontab /etc/cron.d/*; do
        [[ -f "$f" ]] || continue
        shell=/bin/sh
        while read -r min hour dom mon dow user cmd; do
            [[ "$min" == SHELL=* ]] && { shell=${min#SHELL=}; continue; }
            [[ -z "$min" || "$min" == \#* || "$min" == *=* ]] && continue
            [[ "$user" == "ralph" ]] || continue
            if schedule_ok "$min" "$hour" "$dom" "$mon" "$dow"; then
                job_cmd=$cmd; job_shell=$shell; break 2
            fi
        done < <(sudo cat "$f" 2>/dev/null)
    done
fi

[[ -n "$job_cmd" ]] || fail

# cron ends the command at the first unescaped %, and turns \% into %.
job_cmd=${job_cmd//\\%/$'\x01'}
job_cmd=${job_cmd%%%*}
job_cmd=${job_cmd//$'\x01'/%}
[[ -x "$job_shell" ]] || job_shell=/bin/sh

# --- Run the command as cron would (as ralph, from his home, with his
#     crontab's SHELL) TWICE: an overwrite (>) instead of an append (>>)
#     would still leave one line on an empty log. Time-limited, so a
#     hanging command can't hang the check. Then put the log back exactly
#     as it was.
backup=$(mktemp)
had_log=0
if sudo test -e "$LOG"; then had_log=1; sudo cp -p "$LOG" "$backup"; fi
before=$(sudo sh -c "wc -l < '$LOG'" 2>/dev/null || echo 0)

for run in 1 2; do
    sudo -u ralph -H timeout 10 "$job_shell" -c "cd ~ && $job_cmd" </dev/null &>/dev/null
done

after=$(sudo sh -c "wc -l < '$LOG'" 2>/dev/null || echo 0)
last=$(sudo tail -n 1 "$LOG" 2>/dev/null)

if (( had_log )); then sudo cp -p "$backup" "$LOG"; else sudo rm -f "$LOG"; fi
sudo rm -f "$backup"

(( after == before + 2 ))           || fail
[[ "$last" == *"$(date +%Y)"* ]]    || fail

pass
