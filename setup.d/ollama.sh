#!/bin/bash

# Ollama manual installation script
# Based on: https://github.com/ollama/ollama/blob/main/docs/linux.md

echo "Installing Ollama manually..."

# Check if upgrading from prior version and remove old libraries
if [ -d "/usr/lib/ollama" ]; then
    echo "Removing old Ollama libraries..."
    sudo rm -rf /usr/lib/ollama
fi

# Download and extract the package
echo "Downloading Ollama for Linux AMD64..."
curl -LO https://ollama.com/download/ollama-linux-amd64.tgz

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to download Ollama package"
    exit 1
fi

echo "Extracting Ollama package..."
sudo tar -C /usr -xzf ollama-linux-amd64.tgz

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to extract Ollama package"
    exit 1
fi

# Clean up downloaded archive
rm ollama-linux-amd64.tgz

# Create ollama user and group for the service
echo "Creating ollama user and group..."
sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama 2>/dev/null || true
sudo usermod -a -G ollama $(whoami)

# Create systemd service file
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/ollama.service > /dev/null << 'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=$PATH"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo "Enabling Ollama service..."
sudo systemctl daemon-reload
sudo systemctl enable ollama

# Start the service
echo "Starting Ollama service..."
sudo systemctl start ollama

# Wait a moment for service to start
sleep 3

# Verify installation
echo "Verifying Ollama installation..."
if sudo systemctl is-active --quiet ollama; then
    echo "Ollama service is running successfully"
    
    # Test ollama command
    if command -v ollama >/dev/null 2>&1; then
        echo "Ollama binary is accessible"
        ollama --version
        echo ""
        echo "Ollama installation completed successfully!"
        echo "You can now run 'ollama pull <model>' to download models"
        echo "Example: ollama pull llama3.2"
    else
        echo "WARNING: Ollama binary not found in PATH"
        exit 1
    fi
else
    echo "ERROR: Ollama service failed to start"
    echo "Check logs with: sudo journalctl -e -u ollama"
    exit 1
fi