#!/bin/bash

# Create a reference file with expected replacements
wget -qO- "https://raw.githubusercontent.com/ertyased2/characters_list/refs/heads/main/characters.txt" | sed 's/from/appears in/g' > /tmp/expected_characters.txt

# Compare the modified file to the expected output
if cmp -s /home/student/characters.txt /tmp/expected_characters.txt; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

# Cleanup the temporary reference file
rm /tmp/expected_characters.txt
