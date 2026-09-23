#!/bin/bash

# Ensure daffy exists
if ! id "daffy" &>/dev/null; then
    echo "Error: User daffy does not exist. Run the setup script."
    exit 1
fi

overall_pass=true

# --- Check 1: login shell (reads /etc/profile -> ~/.bash_profile) ---
login_result=$(sudo -i -u daffy bash <<'EOF'
    rm -f ~/testfile_login
    rm -rf ~/testdir_login
    touch ~/testfile_login
    mkdir ~/testdir_login
    file_perm=$(stat -c "%a" ~/testfile_login)
    dir_perm=$(stat -c "%a" ~/testdir_login)
    rm -f ~/testfile_login
    rm -rf ~/testdir_login
    echo "$file_perm $dir_perm"
EOF
)
login_file_perm=$(echo "$login_result" | tail -1 | awk '{print $1}')
login_dir_perm=$(echo "$login_result" | tail -1 | awk '{print $2}')

if [[ "$login_file_perm" == "644" && "$login_dir_perm" == "755" ]]; then
    echo -e "\e[32mLogin shell (~/.bash_profile): PASS\e[0m"
else
    echo -e "\e[31mLogin shell (~/.bash_profile): FAIL\e[0m"
    echo "  File permission: $login_file_perm (Expected: 644)"
    echo "  Directory permission: $login_dir_perm (Expected: 755)"
    overall_pass=false
fi

# --- Check 2: non-login interactive shell (reads ~/.bashrc) ---
nonlogin_result=$(sudo -u daffy bash -ic '
    rm -f ~/testfile_nonlogin
    rm -rf ~/testdir_nonlogin
    touch ~/testfile_nonlogin
    mkdir ~/testdir_nonlogin
    file_perm=$(stat -c "%a" ~/testfile_nonlogin)
    dir_perm=$(stat -c "%a" ~/testdir_nonlogin)
    rm -f ~/testfile_nonlogin
    rm -rf ~/testdir_nonlogin
    echo "$file_perm $dir_perm"
' 2>/dev/null)
nonlogin_file_perm=$(echo "$nonlogin_result" | tail -1 | awk '{print $1}')
nonlogin_dir_perm=$(echo "$nonlogin_result" | tail -1 | awk '{print $2}')

if [[ "$nonlogin_file_perm" == "644" && "$nonlogin_dir_perm" == "755" ]]; then
    echo -e "\e[32mNon-login shell (~/.bashrc): PASS\e[0m"
else
    echo -e "\e[31mNon-login shell (~/.bashrc): FAIL\e[0m"
    echo "  File permission: $nonlogin_file_perm (Expected: 644)"
    echo "  Directory permission: $nonlogin_dir_perm (Expected: 755)"
    overall_pass=false
fi

echo ""
if $overall_pass; then
    echo -e "\e[32mSUCCESS!\e[0m"
    exit 0
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
    echo "Failure: Incorrect umask settings. Check both ~/.bash_profile and ~/.bashrc."
    exit 1
fi
