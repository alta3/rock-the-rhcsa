#!/bin/bash

# Check if a container named toystory is running with nginx:examprep image and has /home/student/woody mounted to /buzz
if sudo podman inspect toystory &>/dev/null && \
   sudo podman inspect toystory | grep -q '"Source": "/home/student/woody"' && \
   sudo podman inspect toystory | grep -q '"Destination": "/buzz"'; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
