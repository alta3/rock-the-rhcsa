#!/bin/bash

# Uninstall httpd if it's installed
sudo yum remove -y httpd &>/dev/null

echo "Setup is complete. Begin your task!"
