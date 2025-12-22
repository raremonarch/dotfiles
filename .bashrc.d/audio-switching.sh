#!/bin/bash
alias headset='pactl set-default-sink bluez_output.00_04_32_CA_5B_12.1'
alias speakers='pactl set-default-sink alsa_output.pci-0000_28_00.4.analog-stereo'
alias headset-pair='bluetoothctl pair 00:04:32:CA:5B:12 && bluetoothctl connect 00:04:32:CA:5B:12 && bluetoothctl trust 00:04:32:CA:5B:12'
