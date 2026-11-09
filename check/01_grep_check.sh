#!/bin/bash
# 01_grep_check.sh (RHCSA practice)
# aquarium.txt must be exactly the lines of animals.txt that contain "fish"
# (any case), in their original order, with no extra blank lines.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

input_file="/home/student/animals.txt"
output_file="/home/student/aquarium.txt"

if [[ ! -s "$input_file" ]]; then
    echo "$input_file is missing or empty - run the setup script for this task first."
    exit 2
fi

[[ -s "$output_file" ]] || fail

cmp -s <(grep -i 'fish' "$input_file") "$output_file" || fail

pass
