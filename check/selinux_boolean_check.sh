#!/bin/bash

# Check the SELinux Boolean value
if sudo getsebool logrotate_read_inside_containers | grep -q "on"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
