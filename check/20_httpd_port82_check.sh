#!/bin/bash

# Check if httpd is running on port 82 and returns the expected content
if curl -s localhost:82 | grep -q "Wubba Lubba Dub Dub!"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi

