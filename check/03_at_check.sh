#!/bin/bash
# 03_at_check.sh (RHCSA practice)
# /home/student/homer_quote.sh must be executable, print the quote and append
# it to /home/student/homer_output.txt, and be scheduled with at, by student,
# for midnight.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

SCRIPT=/home/student/homer_quote.sh
OUT=/home/student/homer_output.txt
QUOTE='Oh, so they have Internet on computers now!'

[[ -x "$SCRIPT" ]] || fail
command -v atq &>/dev/null || fail

# --- The script does what it should. Run it as student, then put the output
#     file back exactly as it was.
backup=$(mktemp)
had_out=0
if [[ -e "$OUT" ]]; then had_out=1; cp -p "$OUT" "$backup"; fi

stdout=$(sudo -u student "$SCRIPT" 2>/dev/null)
last_line=$(tail -n 1 "$OUT" 2>/dev/null)

if (( had_out )); then cp -p "$backup" "$OUT"; else rm -f "$OUT"; fi
rm -f "$backup"

[[ "$stdout" == *"$QUOTE"* ]]   || fail
[[ "$last_line" == "$QUOTE" ]]  || fail

# --- A job owned by student, at exactly 00:00:00, that runs the script.
#     atq format: <job> <Day> <Mon> <DD> <HH:MM:SS> <YYYY> <queue> <user>
found=0
while read -r job _ _ _ time _ _ user; do
    [[ "$time" == "00:00:00" && "$user" == "student" ]] || continue
    if sudo at -c "$job" 2>/dev/null | grep -q "homer_quote.sh"; then
        found=1
        break
    fi
done < <(sudo atq 2>/dev/null)

(( found )) || fail
pass
