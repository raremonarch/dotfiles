#!/bin/bash

# Exit on any error
set -e

echo -n "installing and configuring Docker ... "

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed"
    return 0
fi

# Install Docker engine from official repository
echo -n "setting up Docker repository ... "
if sudo dnf config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo" 2>/dev/null; then
    echo "done"
else
    echo "failed to add Docker repository"
    exit 1
fi

echo -n "installing Docker packages ... "
if sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
    echo "done"
else
    echo "failed to install Docker packages"
    exit 1
fi

# Start and enable Docker service
echo -n "starting Docker service ... "
sudo systemctl start docker
sudo systemctl enable docker
echo "done"

# Configure Docker group for non-root access
echo -n "configuring Docker group access ... "
sudo groupadd docker 2>/dev/null || true  # Group might already exist
sudo gpasswd -a ${USER} docker
sudo systemctl restart docker
echo "done (logout/login required for group changes to take effect)"

echo "Docker installation complete"