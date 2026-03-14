#!/bin/bash
# Show pending pacman update count. Outputs nothing on non-Arch systems.
command -v checkupdates >/dev/null 2>&1 || exit 0
count=$(checkupdates 2>/dev/null | wc -l)
[ "$count" -gt 0 ] && echo "$count"
