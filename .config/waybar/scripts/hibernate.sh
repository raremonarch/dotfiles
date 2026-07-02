#!/bin/bash
# Validate hibernate prerequisites before attempting hibernation.

SWAPFILE="/swapfile"
errors=()

_is_systemd() { [ "$(ps -o comm= -p 1 2>/dev/null)" = "systemd" ]; }

# Check 1: Swapfile exists
if [ ! -f "$SWAPFILE" ]; then
    errors+=("No swapfile found at $SWAPFILE")
fi

# Check 2: Swapfile in fstab
if ! grep -q "^$SWAPFILE " /etc/fstab 2>/dev/null; then
    errors+=("Swapfile not registered in /etc/fstab")
fi

# Check 3: Kernel resume parameters
if _is_systemd; then
    if ! grep -rq 'resume=' /boot/loader/entries/ 2>/dev/null; then
        errors+=("No resume= kernel parameter in boot loader entries")
    fi
else
    if ! grep -q 'resume=' /etc/default/grub 2>/dev/null; then
        errors+=("No resume= kernel parameter in /etc/default/grub")
    fi
fi

if [ ${#errors[@]} -gt 0 ]; then
    msg="Hibernate is not configured:\n"
    for e in "${errors[@]}"; do
        msg+="• $e\n"
    done
    notify-send -u critical "Hibernate Unavailable" "$msg"
    exit 1
fi

if _is_systemd; then systemctl hibernate; else loginctl hibernate; fi
