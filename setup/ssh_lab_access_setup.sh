#!/bin/bash
# ssh_lab_access_setup.sh (RH124 lab: Access remote systems using SSH) - run on rhel-1
# Creates a fresh throwaway user apu (password: kwikemart) with a few files to
# copy around. Re-running it starts the lab over.
# Does not touch sshd, its config, or the student/root accounts.

USER_NAME=apu
USER_PASS=kwikemart

# Start clean: end any of apu's sessions, then remove and re-create him.
if id "$USER_NAME" &>/dev/null; then
    sudo loginctl terminate-user "$USER_NAME" &>/dev/null
    sleep 1
    sudo userdel -r "$USER_NAME" &>/dev/null
fi
if ! sudo useradd "$USER_NAME"; then
    echo "Could not create the user $USER_NAME - see the error above."
    exit 1
fi
echo "$USER_NAME:$USER_PASS" | sudo chpasswd

# Some files for the transfer steps.
sudo -u "$USER_NAME" bash -c '
mkdir -p ~/reports
for q in 1 2 3 4; do
    printf "Kwik-E-Mart sales report, Q%s\nSquishees sold: %s\n" "$q" "$((q * 1234))" > ~/reports/q$q.txt
done
echo "Thank you, come again!" > ~/motd.txt
'

echo "Setup is complete. Begin the lab!"
