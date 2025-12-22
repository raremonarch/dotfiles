#!/bin/bash
# Module: system-reload
# Version: 0.1.0
# Description: Shell reload utility
# BashMod Dependencies: none

alias reload='exec bash -c "echo \"✓ Shell reloaded\" && exec bash"'
