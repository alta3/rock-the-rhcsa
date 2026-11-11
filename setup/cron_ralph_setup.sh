#!/bin/bash
# cron_ralph_setup.sh (RHCSA practice)
# Creates the user ralph (no password, so no one can log in as him) and
# clears any crontab and log left from an earlier attempt.

if ! id ralph &>/dev/null; then
    if ! sudo useradd ralph; then
        echo "Could not create the user ralph - see the error above."
        exit 1
    fi
fi

sudo crontab -r -u ralph &>/dev/null
sudo rm -f /home/ralph/bus.log

echo "Setup is complete. Begin your task!"
