#!/bin/bash

# Check if the volume group vg-starfleet exists and has a size of approximately 5G
if sudo vgdisplay vg-starfleet &> /dev/null; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
