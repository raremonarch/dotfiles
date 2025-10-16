#!/bin/bash
cd /tmp
wget https://audiolink.dev/gallery/AudioLinkMono.zip
unzip AudioLinkMono.zip -d audiolinkmono
mkdir -p ~/.local/share/fonts
cp audiolinkmono/*.{ttf,otf} ~/.local/share/fonts/
fc-cache -fv
rm -rf AudioLinkMono.zip audiolinkmono