#!/bin/bash
# Run pacman -Syu in a terminal, then signal waybar to refresh the updates module
alacritty -e sudo pacman -Syu
pkill -SIGRTMIN+8 waybar
