list_fonts() {
  echo "Installed fonts:"
  fc-list | awk -F: '{print $2}' | awk -F, '{print $1}' | sed 's/^ //;s/ style=.*$//' | sort | uniq
}
#!/bin/bash

# Usage: ./set-font-everywhere.sh "Font Name" FontSize
# Example: ./set-font-everywhere.sh "Hack Nerd Font" 11


set -e

FONT_NAME="$1"
FONT_SIZE="$2"

ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
GTK3_CONF="$HOME/.config/gtk-3.0/settings.ini"
GTK2_CONF="$HOME/.gtkrc-2.0"
I3_CONF="$HOME/.config/i3/config"

backup() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
    # Keep only the 2 most recent backups
    local backups=("${file}.bak."*)
    if [ ${#backups[@]} -gt 2 ]; then
      # Sort and delete oldest
      ls -1t "${file}.bak."* | tail -n +3 | xargs -r rm --
    fi
  fi
}

check_args() {
  if [ "$FONT_NAME" = "--list-installed" ]; then
    list_fonts
    exit 0
  fi
  if [ -z "$FONT_NAME" ] || [ -z "$FONT_SIZE" ]; then
    echo "Usage: $0 <Font Name> <Font Size>"
    echo "       $0 --list-installed"
    exit 1
  fi
}

check_font_installed() {
  if ! fc-list | grep -Fq "$FONT_NAME"; then
    echo "Error: Font '$FONT_NAME' not found in installed fonts."
    echo "Run: $0 --list-installed  to see available font names."
    exit 2
  fi
}

update_alacritty() {
  echo "Updating Alacritty config..."
  backup "$ALACRITTY_CONF"
  tmpfile=$(mktemp)
  awk -v font="$FONT_NAME" -v size="$FONT_SIZE" '
    BEGIN {in_font=0}
    /^\[font\]/ {in_font=1; print; next}
    in_font && /^[^[]/ {
      if ($0 ~ /normal\.family\s*=.*/) print "normal.family = \"" font "\"";
      else if ($0 ~ /bold\.family\s*=.*/) print "bold.family = \"" font "\"";
      else if ($0 ~ /italic\.family\s*=.*/) print "italic.family = \"" font "\"";
      else if ($0 ~ /size\s*=.*/) print "size = " size ".0";
      else print;
      next
    }
    {if ($0 ~ /^\[/ && in_font) in_font=0; print}
  ' "$ALACRITTY_CONF" > "$tmpfile" && mv "$tmpfile" "$ALACRITTY_CONF"
}


update_gtk3() {
  echo "Updating GTK3 config..."
  backup "$GTK3_CONF"
  awk -v font="$FONT_NAME" -v size="$FONT_SIZE" '
    BEGIN {in_settings=0; found=0}
    /^\[Settings\]/ {in_settings=1; print; next}
    /^\[/ && !/^\[Settings\]/ {if(in_settings){in_settings=0} print; next}
    in_settings && /^gtk-font-name=/ {
      print "gtk-font-name=" font " " size; found=1; next
    }
    {print}
    END {if (in_settings && !found) print "gtk-font-name=" font " " size}
  ' "$GTK3_CONF" > "$GTK3_CONF.tmp" && mv "$GTK3_CONF.tmp" "$GTK3_CONF"
}


update_gtk2() {
  echo "Updating GTK2 config..."
  backup "$GTK2_CONF"
  sed -i "/^gtk-font-name=/c\gtk-font-name=\"$FONT_NAME $FONT_SIZE\"" "$GTK2_CONF" 2>/dev/null || true
}

update_i3() {
  echo "Updating i3 config..."
  backup "$I3_CONF"
  sed -i "/^font\s/c\font pango:$FONT_NAME $FONT_SIZE" "$I3_CONF" 2>/dev/null || true
  # Reload i3 to apply changes
  if command -v i3-msg >/dev/null 2>&1; then
    echo "Reloading i3..."
    i3-msg reload >/dev/null
  else
    echo "i3-msg not found; please reload i3 manually."
  fi
}


main() {
  check_args
  check_font_installed
  echo "Setting font to: $FONT_NAME ... "
  update_alacritty
  update_gtk3
  update_gtk2
  update_i3
  echo "Done! Please restart your applications or reload configs to see changes."
}

main
