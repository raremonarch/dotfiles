#!/bin/bash

# Check if hostname is provided as first parameter
if [ -z "$1" ]; then
    echo "Error: No hostname provided. Usage: $0 <new_hostname>"
    exit 1
fi

# Update hostname
new_hostname="$1"
sudo hostnamectl hostname "$1"

# Verify update
if [ "$(hostname)" = "$1" ]; then
    echo "hostname updated to '$new_hostname'"
else
    echo "ERROR: failed to update hostname"
    exit 1
fi