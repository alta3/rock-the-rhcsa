#!/bin/bash

# Check if the result file exists
if [[ ! -f /home/student/moviematches.txt ]]; then
    echo -e "\e[31mNO PASS- TRY AGAIN! File /home/student/moviematches.txt not found.\e[0m"
    exit 1
fi

# Verify that the file contains matches for "harry"
if grep -i "harry" /home/student/movie-characters.txt | diff -q - /home/student/moviematches.txt &>/dev/null; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN! The file does not contain the correct matches.\e[0m"
fi
