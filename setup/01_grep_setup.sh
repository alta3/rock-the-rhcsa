#!/bin/bash
# 01_grep_setup.sh (RHCSA practice)

URL="https://raw.githubusercontent.com/alta3/rock-the-rhcsa/main/resources/animals.txt"
DEST="/home/student/animals.txt"

# Download animals.txt, overwriting it if it exists
if curl -fsSL -o "$DEST" "$URL" && [[ -s "$DEST" ]]; then
    echo "Setup complete!"
else
    echo "Could not download $URL - check your internet connection and run this setup again."
    exit 1
fi
