#!/bin/bash

# Ensure wget is installed
if ! command -v wget &>/dev/null; then
    sudo yum install -y wget
fi

# Download the movie-characters.txt file
wget -q -O /home/student/movie-characters.txt https://raw.githubusercontent.com/webpwnized/byepass/refs/heads/master/dictionaries/movie-characters.txt
