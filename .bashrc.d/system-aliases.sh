#!/bin/bash
# Module: system-aliases
# Version: 0.1.0
# Description: Common system aliases and helper discovery function
# BashMod Dependencies: none

alias lsp="ls -lahp"
alias calc='gnome-calculator'
alias pwdsize='du -sh .'
alias llama='ollama run llama3'
alias kit='~/code/daevski/kitbash/kit-start.sh'
alias ssh-macmini='ssh -i ~/.ssh/id_ed25519 debian@192.168.0.128'

function aliases() {
  local filter="$1"

  echo "=== Aliases and Functions in ~/.bashrc.d/ ==="
  if [[ -n "$filter" ]]; then
    echo "=== Filtering for: $filter ==="
  fi
  echo ""

  for script in ~/.bashrc.d/*.sh; do
    if [ -f "$script" ]; then
      filename=$(basename "$script")

      # Skip files that don't match the filter
      if [[ -n "$filter" ]] && [[ ! "$filename" =~ $filter ]]; then
        continue
      fi

      echo "📁 $filename"
      echo "$(printf '%.0s─' {1..40})"

      # Find aliases and extract names
      grep "^alias " "$script" 2>/dev/null | sed 's/^alias \([^=]*\)=.*/\1/' | while read -r name; do
        case "$name" in
          calc) echo "  $name - Launch calculator" ;;
          pwdsize) echo "  $name - Show current directory size" ;;
          tstamp) echo "  $name - Copy timestamp to clipboard" ;;
          fproc|psg) echo "  $name - Search running processes" ;;
          llama) echo "  $name - Run Llama3 AI model" ;;
          gitaddcommit) echo "  $name - Git add all and commit with message" ;;
          *) echo "  $name" ;;
        esac
      done

      # Find functions (both syntaxes) and extract names
      {
        grep "^function " "$script" 2>/dev/null | sed 's/^function \([^(]*\).*/\1/'
        grep "^[a-zA-Z_][a-zA-Z0-9_-]*() {" "$script" 2>/dev/null | sed 's/() {.*//'
      } | while read -r name; do
        case "$name" in
          confi3) echo "  $name - Edit i3 config file" ;;
          addpack) echo "  $name - Add package to list and install" ;;
          rmpack) echo "  $name - Remove package from list and system" ;;
          format-usb) echo "  $name - Format USB drive as FAT32" ;;
          aliases) echo "  $name - Show all aliases and functions" ;;
          clone-eis) echo "  $name - Clone EIS repository" ;;
          clone-daev) echo "  $name - Clone personal repository" ;;
          git-del-branch) echo "  $name - Delete branch locally and remotely" ;;
          docker-nukec) echo "  $name - Stop and remove all containers" ;;
          docker-purge-all) echo "  $name - Remove all Docker data" ;;
          cdpydev) echo "  $name - Change to Python development directory" ;;
          poetryreq) echo "  $name - Export Poetry requirements" ;;
          pycov) echo "  $name - Run pytest with coverage (skip covered)" ;;
          pycov-all) echo "  $name - Run pytest with full coverage report" ;;
          coverage-check) echo "  $name - Check coverage meets 80% threshold" ;;
          *) echo "  $name" ;;
        esac
      done

      echo ""
    fi
  done
}
