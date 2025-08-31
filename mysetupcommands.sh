#!/bin/sh

_step='> '
_hostname=ideapod3
_lightdm_image=$HOME/Pictures/dusk-mountain.jpg

## CONFIG ABOVE; SCRIPT BELOW ##

# ask user to do the sudo
echo
echo -n "we gonna be usin' sudo... "
sudo echo "ok"

echo -n "$_step setting lightdm (login) background image... "
sudo cp $_lightdm_image /usr/share/pixmaps/wallpaper.jpg && \
sudo sed -i "/^\[greeter\]/, /^\[/ s|^background=.*|background=/usr/share/pixmaps/wallpaper.jpg|" /etc/lightdm/lightdm-gtk-greeter.conf && echo 'done'

#set touchpad stuff
echo -n "$_step setting hostname to $_hostname... "
sudo hostnamectl set-hostname ideapod3 && echo "done"

# add user to video group for 'light' (brightness) package usage
echo -n "$_step adding user to 'video' gtroup for brightness controls... "
sudo usermod -a -G video $USER && echo 'done'

# add vscode via packagher repository
echo "$_step adding MS vscode package repository... "
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null && dnf check-update > /dev/null && echo "done"

echo "allll done!"
