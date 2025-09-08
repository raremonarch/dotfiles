fastfetch # displays system details when terminal loads
alias calc='galculator'
alias pwdsize='du -sh .'
alias tstamp='~/Scripts/timestamp-to-clipboard.sh'

function confi3() {
  vim ~/.config/i3/config
}

# custom package add/rm (fedora)
mypackages_file=~/mypackages.txt
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
