#!/usr/bin/env bash

core_packages='
cinnamon
gnome-terminal
gvfs-smb
lightdm
lightdm-gtk-greeter
pavucontrol
pulseaudio
pulseaudio-alsa
xorg
'
# gnome-system-monitor
# mate-icon-theme

essential_packages='
age
android-tools
android-udev
aria2
chromium
d2
deno
ditaa
fdupes
figlet
firefox
gimp
git
gnome-disk-utility
go
gvim
handbrake
handbrake-cli
inkscape
jhead
keepassxc
libdvdcss
librecad
libreoffice-fresh
openscad
perl-rename
rsync
thunderbird
tk
tmux
tree
wireguard-tools
yt-dlp
'
# unison
# yggdrasil

pacman --noconfirm --sync ${core_packages} ${essential_packages}

# Foreign packages (pacman -Qm -q)
# brlaser
# electron30-bin
# filespooler
# geteltorito
# gojq
# infnoise
# infnoise-tools
# libinfnoise
# nncp
# pdfcpu
# ptouch-print-git
# reticulum-meshchat-bin
# tncattach

systemctl enable lightdm
systemctl enable NetworkManager

# gsettings set org.cinnamon.desktop.interface cursor-theme Adwaita
# gsettings set org.gnome.nm-applet disable-connected-notifications true
# gsettings set org.gnome.nm-applet disable-disconnected-notifications true
# gsettings set org.gnome.nm-applet disable-vpn-notifications true
# sudo systemctl enable sshd
# sudo systemctl start sshd

# dark mode enabled
# window behaviour "focus follows mouse" enabled
# date/time applet settings updated (show week numbers, custom date format "%a, %b %e, %H:%M")
# battery applet settings updated (show all batteries, show percentage)
# grouped window applet settings updated
# remove pinned icons from bottom panel
# desktop icons settings updated (show trash and mounted drives)
# network settings updated (join wireless network)
# gthumb settings updated
# nemo settings updated
# keepassxc settings updated
# firefox settings updated
# thunderbird settings updated
