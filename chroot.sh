#!/usr/bin/env bash

# Set up timezone and clock
ln -s "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc --utc

# Set up locale and keymap
LOCALE="en_CA"
ENCODING="UTF-8"
KEYMAP="us"
sed -i "/^#${LOCALE}.${ENCODING} ${ENCODING} /s/^#//" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}.${ENCODNIG}" > /etc/locale.conf
export "LANG=${LOCALE}.${ENCODNIG}"
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# Set up hostname and hosts file
if [ ! -z "${HOSTNAME}" ]; then
  echo "${HOSTNAME}" > /etc/hostname
  hostname "${HOSTNAME}"
  echo "127.0.1.1  ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts
  echo "ff02::1  ip6-allnodes" >> /etc/hosts
  echo "ff02::2  ip6-allrouters" >> /etc/hosts
fi

# Set up networking junk
systemctl enable dhcpcd
# XXX do more stuff here XXX
#pacman -S --noconfirm dhclient

# Set up users and groups
#PASSWORD="hello"
# XXX do more stuff here XXX
#passwd

# Build initrd
#pacman -Syy  # update things?
#pacman -S --noconfirm lvm2  # already in base
#pacman -S --noconfirm cryptsetup  # already in base
# XXX do more stuff here XXX
# /etc/mkinitcpio.conf
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
#mkinitcpio -p linux

# Boot loader stuff
# If UEFI is enabled
# ls /sys/firmware/efi/efivars
pacman -S --noconfirm grub
grub-install --target=i386-pc "${BOOTDEVICE}"
grub-mkconfig -o /boot/grub/grub.cfg
# XXX do more stuff here XXX
