#!/bin/bash

# Check if logrotate is configured for daily rotation, five-day retention, and compression
if grep -q "daily" /etc/logrotate.conf && \
   grep -q "rotate 5" /etc/logrotate.conf && \
   grep -q "compress" /etc/logrotate.conf; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
