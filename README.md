# Dotfiles & Fedora Setup System

This repository manages configuration files (dotfiles) and provides a modular setup system for fresh Fedora installations. The configuration files (i.e., `~/.config` and the like) are version-controlled, while the `setup.sh`/`setup.d/` scripts handle system configuration, package installation, and dynamic updates that are not captured in the configuration files. 

This project is a work-in-progress and will likely change based on my personal preferences... but the modular `setup.sh` tool may be useful to other linux users! Read on to learn more!

## Quick Start

### 🚀 One-Line Installation (Recommended)

```bash
# Interactive setup (will prompt for repository and preferences)
curl -fsSL https://raw.githubusercontent.com/daevski/dotfiles/main/setup.sh | bash

# Use defaults (no prompts)
curl -fsSL https://raw.githubusercontent.com/daevski/dotfiles/main/setup.sh | bash -s -- --defaults

# Use your own fork
curl -fsSL https://raw.githubusercontent.com/daevski/dotfiles/main/setup.sh | bash -s -- --repo yourusername/dotfiles
```

### 📋 Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/daevski/dotfiles.git
   cd dotfiles
   ```

2. **Run the setup:**
   ```bash
   # Run all configured modules
   ./run-setup.sh

   # Or run specific modules
   ./run-setup.sh wallpaper
   ./run-setup.sh vscode
   ./run-setup.sh help  # See all available options
   ```

## Setup System Architecture

### Configuration File (`setup.conf`)
The `setup.conf` file contains all your preferences:

```bash
# Required preferences
_hostname='desktop'
_editor='vim'
_wallpaper='~/Pictures/current_wallpaper.jpg'
_cursor='breeze_cursors'

# Optional modules (true/false)
_docker=false
_vscode=true
_google_chrome=true
# ... etc
```

### Modular Scripts (`setup.d/`)
Each feature has its own script in `setup.d/`:
- `wallpaper.sh` - Wallpaper configuration for desktop, lock screen, and login
- `vscode.sh` - VS Code installation and configuration
- `docker.sh` - Docker installation and user setup
- `cursor.sh` - Cursor theme configuration
- `editor.sh` - Default editor configuration
- And many more...

### Usage Examples

```bash
# Bootstrap script (for fresh systems)
curl -fsSL https://raw.githubusercontent.com/daevski/dotfiles/main/setup.sh | bash

# After bootstrap, use run-setup.sh for management:
~/run-setup.sh                    # Run everything configured in setup.conf
~/run-setup.sh wallpaper          # Run specific modules
~/run-setup.sh vscode docker      # Multiple modules
~/run-setup.sh help               # Get help

# Override preferences for one-time use
~/run-setup.sh wallpaper ~/Pictures/new-wallpaper.jpg
~/run-setup.sh editor code
```

### Dynamic Wallpaper Features
The wallpaper system automatically:
- Detects dual-monitor setups and splits ultra-wide images
- Configures desktop, lock screen, and login wallpapers
- Updates Sway, swaylock, and SDDM configurations
- Handles different aspect ratios appropriately

## Dotfiles Integration

### For New Systems
The setup scripts will use the configuration files from this repository. Simply run `./setup.sh` after cloning.

### For Existing Systems
To integrate this repository with your existing home directory:

1. **Clone to temporary location:**
   ```bash
   git clone https://github.com/daevski/dotfiles.git /tmp/dotfiles
   ```

2. **Copy git metadata:**
   ```bash
   cp -r /tmp/dotfiles/.git ~/
   cp /tmp/dotfiles/.gitignore ~/
   ```

3. **Review and merge configurations:**
   Compare the repository configs with your existing files and merge as needed.

4. **Track changes:**
   ```bash
   cd ~
   git add .
   git commit -m "Integrate existing dotfiles"
   git push
   ```

## Key Features

- **Modular Design**: Each feature is self-contained and can be run independently
- **Configuration-Driven**: All preferences centralized in `setup.conf`
- **Dynamic Discovery**: Scripts automatically discover and validate available modules
- **Dual Monitor Support**: Intelligent wallpaper handling for multiple displays
- **Version-Controlled Configs**: All dotfiles tracked in git, scripts only update dynamic values
- **Fedora Optimized**: Designed specifically for Fedora Linux installations

## Advanced Usage

### Creating Custom Modules
Add new scripts to `setup.d/` and corresponding preferences to `setup.conf`. The system will automatically discover them.

### Environment Variables
The system uses `~/.config/environment.d/` for environment configuration, ensuring compatibility with systemd user sessions.

### Validation
The setup system validates all preferences and modules before execution, preventing runtime errors.

---

**Note**: Always review the setup.conf file and individual scripts before running on a new system to ensure they match your requirements.
