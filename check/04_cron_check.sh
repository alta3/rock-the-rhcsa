#!/bin/bash

# Check for the cron job entry that runs every five minutes and tars /etc to bowser_capture.tar.gz
if sudo crontab -l -u student | grep -q "*/5 * * * *" && \
   sudo crontab -l -u student | grep -q "tar" && \
   sudo crontab -l -u student | grep -q "/home/student/bowser_capture.tar.gz"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
