#!/bin/bash

# Mount and Symlink Management Script
# Configures network and local mount points and creates convenience symlinks

echo "Setting up mounts and symlinks..."

# Function to process mount configurations
process_mount_config() {
    local config="$1"
    local mount_type="$2"
    
    # Skip comments
    [[ "$config" =~ ^[[:space:]]*# ]] && return 0
    
    # Parse configuration: "source:mount_point:home_symlink,option1=value,option2=value"
    IFS=':' read -r source mount_point symlink_and_options <<< "$config"
    
    # Split symlink and options
    IFS=',' read -r home_symlink options <<< "$symlink_and_options"
    
    # Expand tilde in home_symlink and credential files
    home_symlink=$(eval echo "$home_symlink")
    
    echo ""
    echo "Processing ($mount_type): $source -> $mount_point -> $home_symlink"
    
    # Determine filesystem type and build mount options based on mount type
    if [ "$mount_type" = "network" ]; then
        if [[ "$source" == //* ]]; then
            # CIFS/SMB share
            fs_type="cifs"
            base_options="uid=$USER,gid=$USER,file_mode=0777,dir_mode=0777,_netdev"
            
            # Process custom options
            if [ -n "$options" ]; then
                # Expand tilde in credential file paths
                processed_options=""
                for opt in $(echo "$options" | tr ',' ' '); do
                    if [[ "$opt" == credfile=* ]]; then
                        credpath="${opt#credfile=}"
                        credpath=$(eval echo "$credpath")
                        processed_options="${processed_options},credentials=$credpath"
                    else
                        processed_options="${processed_options},$opt"
                    fi
                done
                mount_options="$fs_type,$base_options$processed_options"
            else
                mount_options="$fs_type,$base_options"
            fi
        else
            # Assume NFS
            fs_type="nfs"
            mount_options="nfs,defaults,_netdev"
            if [ -n "$options" ]; then
                mount_options="$mount_options,$options"
            fi
        fi
    else
        # Local mount
        fs_type="exfat"
        base_options="uid=$USER,gid=$USER,dmask=0022,fmask=0133"
        
        if [ -n "$options" ]; then
            mount_options="$fs_type,$base_options,$options"
        else
            mount_options="$fs_type,$base_options"
        fi
    fi
    
    # Create mount point directory
    echo -n "  creating mount point '$mount_point' ... "
    if sudo mkdir -p "$mount_point"; then
        echo "done"
    else
        echo "failed"
        continue
    fi
    
    # Set proper ownership for mount point
    echo -n "  setting ownership of '$mount_point' ... "
    if sudo chown "$USER:$USER" "$mount_point"; then
        echo "done"
    else
        echo "failed (continuing anyway)"
    fi
    
    # Create home symlink if specified
    if [ -n "$home_symlink" ]; then
        # Create home symlink directory if it doesn't exist
        symlink_dir=$(dirname "$home_symlink")
        if [ ! -d "$symlink_dir" ]; then
            echo -n "  creating symlink directory '$symlink_dir' ... "
            if mkdir -p "$symlink_dir"; then
                echo "done"
            else
                echo "failed"
                continue
            fi
        fi
        
        # Create or update symlink
        echo -n "  creating symlink '$home_symlink' -> '$mount_point' ... "
        if [ -L "$home_symlink" ]; then
            # Remove existing symlink
            rm "$home_symlink"
        elif [ -e "$home_symlink" ]; then
            echo "failed (target exists and is not a symlink)"
            continue
        fi
        
        if ln -s "$mount_point" "$home_symlink"; then
            echo "done"
        else
            echo "failed"
            continue
        fi
    else
        echo "  skipping symlink creation (none specified)"
    fi
    
    
    # Check if fstab entry exists and update it
    echo -n "  checking /etc/fstab entry ... "
    if grep -q "^[[:space:]]*$source " /etc/fstab 2>/dev/null; then
        echo "found, updating with current options"
        # Remove existing entry and add new one
        sudo sed -i "\|^[[:space:]]*$source |d" /etc/fstab
        echo "$source $mount_point $mount_options 0 0" | sudo tee -a /etc/fstab > /dev/null
        echo "    updated fstab entry"
    elif grep -q "^[[:space:]]*#.*$source " /etc/fstab 2>/dev/null; then
        echo "found commented, updating and enabling"
        # Remove commented entry and add new active one
        sudo sed -i "\|^[[:space:]]*#.*$source |d" /etc/fstab
        echo "$source $mount_point $mount_options 0 0" | sudo tee -a /etc/fstab > /dev/null
        echo "    added active fstab entry"
    else
        echo "missing, adding new entry"
        echo "$source $mount_point $mount_options 0 0" | sudo tee -a /etc/fstab > /dev/null
        echo "    added to fstab"
    fi
    
    # Reload systemd after fstab changes
    echo -n "  reloading systemd units ... "
    if sudo systemctl daemon-reload 2>/dev/null; then
        echo "done"
    else
        echo "failed (continuing anyway)"
    fi
    
    # Check if mount is currently active and mount if needed
    echo -n "  checking mount status ... "
    if mountpoint -q "$mount_point" 2>/dev/null; then
        echo "already mounted"
    else
        echo "not mounted, attempting to mount ... "
        # Try to mount using the generated options
        if sudo mount -t "$fs_type" -o "${mount_options#*,}" "$source" "$mount_point" 2>/dev/null; then
            echo "    successfully mounted"
        else
            echo "    failed to mount (check credentials/network/device availability)"
        fi
    fi
}

# Process network mounts
if [ -n "${_network_mounts[*]}" ]; then
    echo ""
    echo "=== Processing Network Mounts ==="
    for config in "${_network_mounts[@]}"; do
        process_mount_config "$config" "network"
    done
else
    echo "No network mount configurations defined in setup.conf"
fi

# Process local media drives
if [ -n "${_local_media[*]}" ]; then
    echo ""
    echo "=== Processing Local Media Drives ==="
    for config in "${_local_media[@]}"; do
        process_mount_config "$config" "local"
    done
else
    echo "No local media drive configurations defined in setup.conf"
fi

echo ""
echo "=== Mount Setup Results ==="

# Show network mount results
if [ -n "${_network_mounts[*]}" ]; then
    echo "Network Mounts:"
    for config in "${_network_mounts[@]}"; do
        # Skip comments
        [[ "$config" =~ ^[[:space:]]*# ]] && continue
        
        # Parse configuration to get mount point and symlink
        IFS=':' read -r source mount_point symlink_and_options <<< "$config"
        IFS=',' read -r home_symlink options <<< "$symlink_and_options"
        home_symlink=$(eval echo "$home_symlink")
        
        # Check final status
        if mountpoint -q "$mount_point" 2>/dev/null; then
            mount_status="✅ mounted: $mount_point"
        else
            mount_status="❌ not mounted: $mount_point"
        fi
        
        if [ -n "$home_symlink" ]; then
            if [ -L "$home_symlink" ]; then
                symlink_status="✅ linked: $home_symlink"
            else
                symlink_status="❌ no link: $home_symlink"
            fi
            echo "  $source -> $mount_status, $symlink_status"
        else
            echo "  $source -> $mount_status"
        fi
    done
fi

# Show local media drive results
if [ -n "${_local_media[*]}" ]; then
    echo "Local Media Drives:"
    for config in "${_local_media[@]}"; do
        # Skip comments
        [[ "$config" =~ ^[[:space:]]*# ]] && continue
        
        # Parse configuration to get mount point and symlink
        IFS=':' read -r source mount_point symlink_and_options <<< "$config"
        IFS=',' read -r home_symlink options <<< "$symlink_and_options"
        home_symlink=$(eval echo "$home_symlink")
        
        # Check final status
        if mountpoint -q "$mount_point" 2>/dev/null; then
            mount_status="✅ mounted: $mount_point"
        else
            mount_status="❌ not mounted: $mount_point"
        fi
        
        if [ -n "$home_symlink" ]; then
            if [ -L "$home_symlink" ]; then
                symlink_status="✅ linked: $home_symlink"
            else
                symlink_status="❌ no link: $home_symlink"
            fi
            echo "  $source -> $mount_status, $symlink_status"
        else
            echo "  $source -> $mount_status"
        fi
    done
fi

# Function to organize fstab entries into logical groups
organize_fstab() {
    echo ""
    echo "=== Organizing /etc/fstab ==="
    
    local temp_fstab="/tmp/fstab.organized"
    local original_fstab="/etc/fstab"
    
    # Extract the header comments
    echo -n "  organizing fstab entries ... "
    {
        # Header section
        grep "^#" "$original_fstab"
        echo ""
        
        # System mounts (/, /boot, /home, swap)
        echo "# System mounts"
        grep -E "^[^#].*[[:space:]]/(boot|home)?[[:space:]]" "$original_fstab" | grep -v "_netdev"
        echo ""
        
        # Network mounts (anything with _netdev)
        if grep -q "_netdev" "$original_fstab"; then
            echo "# Network mounts"
            grep "_netdev" "$original_fstab" | grep -v "^#"
            echo ""
        fi
        
        # Local media drives (exFAT, NTFS, etc. mounted to /media/)
        if grep -E "^UUID=.*[[:space:]]/media/" "$original_fstab" > /dev/null; then
            echo "# Local media drives"
            grep -E "^UUID=.*[[:space:]]/media/" "$original_fstab"
        fi
        
    } > "$temp_fstab"
    
    # Replace the original fstab with organized version
    if sudo cp "$temp_fstab" "$original_fstab"; then
        echo "done"
        sudo rm -f "$temp_fstab"
    else
        echo "failed"
        rm -f "$temp_fstab"
        return 1
    fi
    
    # Reload systemd after fstab reorganization
    echo -n "  reloading systemd after organization ... "
    if sudo systemctl daemon-reload 2>/dev/null; then
        echo "done"
    else
        echo "failed (continuing anyway)"
    fi
}

# Organize fstab entries after all mounts are configured
organize_fstab