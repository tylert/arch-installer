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

extra_applications='
eog
firefox
libreoffice
thunderbird
totem
'

pacman --noconfirm --sync ${core_packages} ${extra_applications}

systemctl enable lightdm
systemctl enable NetworkManager
