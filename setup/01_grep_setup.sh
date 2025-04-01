#!/bin/bash

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Installing wget..."
    sudo yum install -y wget || sudo apt-get install -y wget
else
    echo "wget is already installed."
fi

# Download animals.txt, overwriting if it exists
wget -O /home/student/animals.txt "https://gist.githubusercontent.com/atduskgreg/3cf8ef48cb0d29cf151bedad81553a54/raw/82f142562cf50b0f6fb8010f890b2f934093553e/animals.txt"

echo "Setup complete!"
