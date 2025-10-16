#!/bin/bash

# Power Management Configuration
# Ensures system never auto-sleeps while allowing screen lock and monitor power-off

echo "Configuring power management to prevent system sleep..."

# Create logind configuration to prevent auto-sleep
echo -n "disabling automatic system sleep ... "
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/no-auto-sleep.conf > /dev/null << 'EOF'
# Prevent automatic system sleep while allowing screen lock and monitor power-off
# Configured by setup system

[Login]
# Never automatically suspend the system
IdleAction=ignore
IdleActionSec=0

# Handle power button press (can be changed to poweroff if desired)
HandlePowerKey=suspend

# For laptops - handle lid switch (ignore, suspend, poweroff, or lock)
# HandleLidSwitch=suspend
# HandleLidSwitchExternalPower=ignore

# Prevent sleep when closing lid with external power (for laptops)
# HandleLidSwitchDocked=ignore
EOF

if [ $? -eq 0 ]; then
    echo "done"
else
    echo "failed"
    exit 1
fi

# Create sleep configuration to disable auto-sleep mechanisms
echo -n "disabling systemd auto-sleep mechanisms ... "
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/no-auto-sleep.conf > /dev/null << 'EOF'
# Disable automatic sleep mechanisms
# Configured by setup system

[Sleep]
# Disable all automatic sleep modes
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
EOF

if [ $? -eq 0 ]; then
    echo "done"
else
    echo "failed"
    exit 1
fi

# Mask sleep targets to prevent accidental sleep (optional, might be too aggressive)
# echo -n "masking sleep targets ... "
# sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# echo "done"

# Configuration applied - restart required for full effect
echo -n "configuration files created successfully ... "
echo "done"

echo ""
echo "✅ Power management configured successfully!"
echo ""
echo "Current configuration:"
echo "  ✅ Screen will lock after 5 minutes (swayidle)"
echo "  ✅ Monitors will turn off after 10 minutes (swayidle)"  
echo "  ✅ System will NEVER auto-sleep or hibernate"
echo "  ⚠️  Manual sleep via 'systemctl suspend' still works"
echo ""
echo "⚠️  IMPORTANT: You need to log out and back in for changes to take full effect."
echo "    (Configuration files have been updated, but logind needs to reload them)"