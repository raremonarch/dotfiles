#!/bin/bash

# Exit on any error
set -e

echo -n "installing Synology Drive ... "

# Check if Synology Drive is already installed
if command -v synology-drive >/dev/null 2>&1; then
    echo "already installed"
    exit 0
fi

# Add Synology Drive COPR repository
echo -n "adding Synology Drive COPR repository ... "
if sudo dnf copr enable emixampp/synology-drive -y 2>/dev/null; then
    echo "done"
else
    echo "failed to enable COPR repository"
    exit 1
fi

# Install Synology Drive
echo -n "installing Synology Drive package ... "
if sudo dnf install -y synology-drive-noextra 2>/dev/null; then
    echo "done"
    echo "Synology Drive installed successfully"
else
    echo "failed to install Synology Drive"
    exit 1
fi