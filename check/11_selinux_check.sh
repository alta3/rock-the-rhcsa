#!/bin/bash

# Check if SELinux is set to enforcing mode both persistently and currently
if grep -q "SELINUX=enforcing" /etc/selinux/config && [[ "$(getenforce)" == "Enforcing" ]]; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
