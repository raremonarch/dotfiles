fastfetch # displays system details when terminal loads
alias calc='galculator'
alias pwdsize='du -sh .'
alias tstamp='~/Scripts/timestamp-to-clipboard.sh'
alias llama='ollama run llama3'

function confi3() {
  vim ~/.config/i3/config
}

# custom package add/rm (fedora)
mypackages_file=~/packages.txt
function addpack() {
  local appname=$1
  echo "$appname" >> "$mypackages_file" && sudo dnf install "$appname" -y
}
function rmpack() {
  local appname=$1
  if grep -q "$appname" "$mypackages_file"; then 
    echo "package '$appname' found in $mypackages_file; removing"
    sed -i "/$appname/d" "$mypackages_file"
    sudo dnf remove "$appname" -y
  else 
    echo "package '$appname' NOT found in $mypackages_file, exiting"
  fi 
}
function format-usb() {
  if [ -z "$1" ]; then
    echo "Usage: format-usb /dev/sdX"
    return 1
  fi
  if [ ! -b "$1" ]; then
    echo "Error: $1 is not a valid block device."
    return 1
  fi
  echo "Device info for $1:"
  echo "---------------------"
  lsblk -o Fare -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,MODEL "$1" | awk 'NR>1 {print "NAME: "$1"\nSIZE: "$2"\nFSTYPE: "$3"\nLABEL: "($4 ? $4 : "None")"\nMOUNTPOINT: "($5 ? $5 : "Not mounted")"\nMODEL: "$6}'
  echo "---------------------"
  echo "WARNING: Formatting $1 will erase all data. Confirm? (y/n)"
  read -r confirm
  if [ "$confirm" != "y" ]; then
    echo "Aborted."
    return 1
  fi
  sudo umount "$1"* 2>/dev/null
  sudo parted "$1" --script mklabel msdos
  sudo mkfs.vfat -F 32 "$1"
  echo "Formatted $1 as FAT32."
}
