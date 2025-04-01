#!/bin/bash

# Check if httpd is installed, running, and enabled
if sudo systemctl is-active --quiet httpd && systemctl is-enabled --quiet httpd; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
