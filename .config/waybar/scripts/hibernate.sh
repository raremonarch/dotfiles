#!/bin/bash
# Validate hibernate prerequisites before attempting hibernation.
# Based on checks from kitbash hibernate module.

SWAPFILE="/swapfile"
errors=()

# Check 1: Swapfile exists
if [ ! -f "$SWAPFILE" ]; then
    errors+=("No swapfile found at $SWAPFILE")
fi

# Check 2: Swapfile in fstab
if ! grep -q "^$SWAPFILE " /etc/fstab 2>/dev/null; then
    errors+=("Swapfile not registered in /etc/fstab")
fi

# Check 3: Kernel resume parameters configured
if ! grep -rq 'resume=' /boot/loader/entries/ 2>/dev/null; then
    errors+=("No resume= kernel parameter in boot entries")
fi

if [ ${#errors[@]} -gt 0 ]; then
    msg="Hibernate is not configured:\n"
    for e in "${errors[@]}"; do
        msg+="• $e\n"
    done
    msg+="\nRun kitbash hibernate module to set up."
    notify-send -u critical "Hibernate Unavailable" "$msg"
    exit 1
fi

systemctl hibernate
