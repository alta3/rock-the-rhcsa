#!/bin/bash

# Create the user 'neo' if it doesn't exist
if ! id "neo" &>/dev/null; then
    sudo useradd neo
fi

echo "Setup is complete. Begin your task!"
