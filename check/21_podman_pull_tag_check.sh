#!/bin/bash

# Check if the nginx image is pulled and tagged as nginx:examprep
if sudo podman images | grep -q "nginx *examprep"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
