#!/bin/sh

_step='> '
_lightdm_image=$HOME/Pictures/dusk-mountain.jpg

## CONFIG ABOVE; SCRIPT BELOW ##

# ask user to do the sudo
echo
echo -n "we gonna be usin' sudo... "
sudo echo "ok"

echo -n "$_step setting lightdm (login) background image... "
sudo cp $_lightdm_image /usr/share/pixmaps/wallpaper.jpg && \
sudo sed -i "/^\[greeter\]/, /^\[/ s|^background=.*|background=/usr/share/pixmaps/wallpaper.jpg|" /etc/lightdm/lightdm-gtk-greeter.conf && echo 'done'

# add user to video group for 'light' (brightness) package usage
echo -n "$_step adding user to 'video' gtroup for brightness controls... "
sudo usermod -a -G video $USER && echo 'done'

# add vscode via package repository
echo "$_step adding MS vscode package repository... "
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null && dnf check-update > /dev/null && echo "done"

# instal docker engine package repository
sudo dnf config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker 
sudo gpasswd -a ${USER} docker
sudo systemctl restart docker
newgrp docker
# NOTE: ^ This change usually requires the user to 
# log out of their desktop session and then back in again.

# install synology drive
sudo dnf copr enable emixampp/synology-drive -y
sudo dnf install synology-drive-noextra -y

# set alacritty as the default terminal system-wide
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
if grep -q "^TerminalEmulator=" ~/.config/xfce4/helpers.rc 2>/dev/null; then
    sed -i 's|^TerminalEmulator=.*|TerminalEmulator=/usr/bin/alacritty|' ~/.config/xfce4/helpers.rc
else
    echo "TerminalEmulator=/usr/bin/alacritty" >> ~/.config/xfce4/helpers.rc
fi

echo "allll done!"
