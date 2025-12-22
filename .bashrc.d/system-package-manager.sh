# Package management utilities (Fedora DNF)

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
