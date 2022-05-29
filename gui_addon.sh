#!/usr/bin/env bash

core_packages='
xorg
cinnamon
gnome-terminal
lightdm
lightdm-gtk-greeter
pulseaudio
pulseaudio-alsa
pavucontrol
gvfs-smb
'
# gnome-system-monitor
# mate-icon-theme

extra_applications='
firefox
thunderbird
libreoffice
eog
totem
'

pacman --noconfirm --sync ${core_packages} ${extra_applications}

systemctl enable lightdm
systemctl enable NetworkManager
