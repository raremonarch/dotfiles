#!/bin/bash
# Font Installation Module
# Downloads and installs fonts from predefined URLs or local paths

FONT_NAME="${1:-$_font}"

if [ -z "$FONT_NAME" ]; then
    echo "ERROR: No font specified"
    return 1
fi

echo "  installing font: $FONT_NAME"

# Ensure fonts directory exists
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

# Check if it's a predefined font
FONT_URL=""
for definition in "${_font_definitions[@]}"; do
    name="${definition%%:*}"
    url="${definition#*:}"
    if [ "$name" = "$FONT_NAME" ]; then
        FONT_URL="$url"
        break
    fi
done

if [ -z "$FONT_URL" ]; then
    echo "  ERROR: Font '$FONT_NAME' not found in predefined fonts"
    echo "  Available fonts:"
    for definition in "${_font_definitions[@]}"; do
        name="${definition%%:*}"
        echo "    - $name"
    done
    return 1
fi

echo "    downloading from: $FONT_URL"

# Download to temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the font
FONT_FILE=$(basename "$FONT_URL")
if ! wget -q "$FONT_URL" -O "$FONT_FILE"; then
    echo "  ERROR: Failed to download font"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Handle zip files
if [[ "$FONT_FILE" == *.zip ]]; then
    echo "    extracting zip archive ..."
    EXTRACT_DIR="font_extracted"
    mkdir -p "$EXTRACT_DIR"
    if ! unzip -q "$FONT_FILE" -d "$EXTRACT_DIR"; then
        echo "  ERROR: Failed to extract font archive"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Copy all font files to fonts directory
    echo "    installing font files ..."
    find "$EXTRACT_DIR" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.TTF" -o -name "*.OTF" \) -exec cp {} "$FONTS_DIR/" \;
else
    # Not a zip, assume it's a direct font file
    echo "    installing font file ..."
    cp "$FONT_FILE" "$FONTS_DIR/"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Rebuild font cache
echo "    rebuilding font cache ..."
fc-cache -fv > /dev/null 2>&1

echo "  font installed successfully"
