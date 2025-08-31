#!/bin/bash

SRC_DIR="$HOME"
DEST_DIR="$(pwd)"

# array for files
FILES=(
  '.bashrc'
  '.gitconfig'
  '.inputrc'
  '.vimrc'
  'mypackages.txt'
  'mysetupcommands.sh'
)

# array for directories
DIRECTORIES=(
  '.bashrc.d/'
  '.config/alacritty/'
  '.config/i3/'
  '.config/i3blocks/'
  '.config/scripts/'
)

echo "Checking files..."
existing_files=()
for file in "${FILES[@]}"; do
  # Ignore .bak files with a timestamp (e.g., file.bak.20250831150703)
  if [[ "$file" =~ \.bak\.[0-9]{14}$ ]]; then
    continue
  fi
  src_file="$SRC_DIR/${file#/}"
  dest_file="$DEST_DIR/${file#/}"
  if [ -f "$src_file" ]; then
    if [ -e "$dest_file" ]; then
      existing_files+=("$dest_file")
    else
      dest_dirname=$(dirname "$dest_file")
      mkdir -p "$dest_dirname"
      echo "Copying file: $src_file -> $dest_file"
      cp "$src_file" "$dest_file"
    fi
  else
    echo "Warning: $src_file not found."
  fi
done

echo "Checking directories..."
existing_dirs=()
for dir in "${DIRECTORIES[@]}"; do
  # Ignore .bak directories with a timestamp (e.g., dir.bak.20250831150703)
  if [[ "$dir" =~ \.bak\.[0-9]{14}/?$ ]]; then
    continue
  fi
  src_dir="$SRC_DIR/${dir#/}"
  dest_dir="$DEST_DIR/${dir#/}"
  if [ -d "$src_dir" ]; then
    if [ -e "$dest_dir" ]; then
      existing_dirs+=("$dest_dir")
    else
      mkdir -p "$(dirname "$dest_dir")"
      echo "Copying directory: $src_dir -> $dest_dir"
      cp -a "$src_dir" "$dest_dir"
      # Remove .bak files with timestamp from the destination directory
      find "$dest_dir" -type f -regextype posix-extended -regex ".*\.bak\.[0-9]{14}$" -exec rm {} +
    fi
  else
    echo "Warning: $src_dir not found."
  fi
done

# Summary of files and directories that already exist
if [ ${#existing_files[@]} -gt 0 ] || [ ${#existing_dirs[@]} -gt 0 ]; then
  echo
  echo "The following files and directories already exist in the destination and were not overwritten:"
  for f in "${existing_files[@]}"; do
    echo "  $f"
  done
  for d in "${existing_dirs[@]}"; do
    echo "  $d"
  done
  echo "Please compare and merge these manually."
fi

echo "Check complete. No files or directories were overwritten."
echo "Any .bak files with a timestamp (e.g., .bak.YYYYMMDDHHMMSS) were removed from the destination directories after copying."