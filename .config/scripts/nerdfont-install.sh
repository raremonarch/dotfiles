#!/bin/bash

if [ "$1" = "--uninstall" ]; then
  FONT="$2"
  FONT_DIR="$HOME/.local/share/fonts"
  if [ -z "$FONT" ]; then
    echo "Usage: $0 --uninstall <font-name>"
    exit 1
  fi
  echo "Uninstalling $FONT Nerd Font from $FONT_DIR..."
  # Remove all files matching the font name (case-insensitive, spaces and dashes ignored)
  shopt -s nocaseglob
  matches=($FONT_DIR/*${FONT// /}*)
  shopt -u nocaseglob
  if [ ${#matches[@]} -eq 0 ]; then
    echo "No files found for $FONT in $FONT_DIR."
    exit 1
  fi
  rm -v "${matches[@]}"
  echo "Updating font cache..."
  fc-cache
  echo "Uninstall done."
  exit 0
fi

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <nerd-font-release> <font-name>"
  echo "       $0 --uninstall <font-name>"
  exit 1
fi

echo "Downloading $FONT Nerd Font version $NF_RELEASE..."

NF_RELEASE=$1
FONT=$2
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v$NF_RELEASE/$FONT.zip"
FONT_ZIP="$HOME/Downloads/$FONT.zip"
FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"
curl -L -o "$FONT_ZIP" "$FONT_URL"
echo "Extracting font files to $FONT_DIR..."
unzip -oq "$FONT_ZIP" -d "$FONT_DIR"
rm "$FONT_ZIP"
echo "Updating font cache..."
fc-cache # Update the font cache
echo "done."
