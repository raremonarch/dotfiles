# Dotfiles

Personal configuration files for my Linux environment (Fedora/Sway). This repository contains dotfiles and system configurations tracked via git in my home directory.

## What's Included

- **Sway**: Window manager configuration
- **Swaylock**: Lock screen settings
- **Bash**: Shell configuration and custom scripts
- **Git**: Version control settings
- **Various apps**: Configuration files for tools and applications

## Installation

### For New Systems

1. **Clone to temporary location:**
   ```bash
   git clone https://github.com/daevski/dotfiles.git /tmp/dotfiles
   ```

2. **Copy git metadata to home directory:**
   ```bash
   cp -r /tmp/dotfiles/.git ~/
   cp /tmp/dotfiles/.gitignore ~/
   ```

3. **Check what would be overwritten:**
   ```bash
   cd ~
   git status
   ```

4. **Review and merge configurations:**
   Compare the repository configs with any existing files and merge as needed.

5. **Reset to repository state (or selectively checkout files):**
   ```bash
   # Option 1: Reset everything to match the repository
   git reset --hard HEAD

   # Option 2: Selectively checkout specific configs
   git checkout .config/sway/config
   git checkout .bashrc
   ```

### For Existing Systems

If you already have configs you want to keep:

1. Follow steps 1-4 above
2. Manually merge any conflicts between your existing configs and the repository
3. Commit your merged configuration:
   ```bash
   cd ~
   git add .
   git commit -m "Integrate existing dotfiles"
   git push
   ```

## Usage

Since this repository uses your home directory as the working tree, you can manage your dotfiles with regular git commands:

```bash
# View changed configurations
git status

# Add modified configs
git add .config/sway/config

# Commit changes
git commit -m "Update sway keybindings"

# Push to remote
git push
```

## Key Features

- **Version-Controlled Configs**: All dotfiles tracked in git
- **Home Directory Integration**: Git repository lives directly in `~`
- **Selective Tracking**: `.gitignore` configured to only track specific config files

---

**Note**: This is a personal configuration repository. Review all files before using them on your own system.
