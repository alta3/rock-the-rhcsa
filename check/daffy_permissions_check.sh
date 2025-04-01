#!/bin/bash

# Ensure daffy exists
if ! id "daffy" &>/dev/null; then
    echo "Error: User daffy does not exist. Run the setup script."
    exit 1
fi

# Run commands inside a full interactive login shell for daffy
sudo -i -u daffy bash <<'EOF'
    rm -f ~/testfile
    rm -rf ~/testdir
    touch ~/testfile
    mkdir ~/testdir
    file_perm=$(stat -c "%a" ~/testfile)
    dir_perm=$(stat -c "%a" ~/testdir)

    if [[ "$file_perm" == "644" && "$dir_perm" == "755" ]]; then
        echo -e "\e[32mSUCCESS!\e[0m"
        exit 0
    else
        echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
        echo "Failure: Incorrect umask settings."
        echo "File permission: $file_perm (Expected: 644)"
        echo "Directory permission: $dir_perm (Expected: 755)"
        exit 1
    fi
EOF
