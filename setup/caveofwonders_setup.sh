#!/bin/bash

# Create the agrabah group if it doesn't exist
if ! sudo getent group agrabah >/dev/null; then
    sudo groupadd agrabah
fi

echo "Setup is complete. Begin your task!"
