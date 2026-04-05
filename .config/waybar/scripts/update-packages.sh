#!/bin/bash
# Run pacman -Syu in a terminal, then signal waybar to refresh the updates module
alacritty -e bash -c 'echo "Running: sudo pacman -Syu --noconfirm"; sudo pacman -Syu --noconfirm'
pkill -SIGRTMIN+8 waybar
