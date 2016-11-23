#!/usr/bin/env bash

# Things to run inside our arch-chroot

set -xe

# ---==[ Set up timezone and clock ]==-----------------------------------------
if [ ! -z "${TIMEZONE}" ]; then
    TIMEZONE="UTC"
else

ln -s "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc --utc

# ---==[ Set up locale and keymap ]==------------------------------------------
if [ ! -z "${LOCALE}" ]; then
    LOCALE="en_CA"
fi
if [ ! -z "${ENCODING}" ]; then
    ENCODING="UTF-8"
fi
if [ ! -z "${KEYMAP}" ]; then
    KEYMAP="us"
fi

sed -i "/^#${LOCALE}.${ENCODING} ${ENCODING} /s/^#//" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}.${ENCODNIG}" > /etc/locale.conf
export "LANG=${LOCALE}.${ENCODNIG}"  # update live environment too
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# ---==[ Set up hostname and hosts file ]==------------------------------------
if [ ! -z "${HOSTNAME}" ]; then
    HOSTNAME="cuckoo"
fi
if [ ! -z "${DOMAIN}" ]; then
    DOMAIN="localdomain"
fi

echo "${HOSTNAME}" > /etc/hostname
hostname "${HOSTNAME}"  # update live environment too
echo "127.0.1.1  ${HOSTNAME}.${DOMAIN}  ${HOSTNAME}" >> /etc/hosts
echo "ff02::1  ip6-allnodes" >> /etc/hosts
echo "ff02::2  ip6-allrouters" >> /etc/hosts

# ---==[ Set up networking junk ]==--------------------------------------------
systemctl enable dhcpcd
# XXX do more stuff here XXX
#pacman -S --noconfirm dhclient

# ---==[ Set up users and groups ]==-------------------------------------------
pacman -S --noconfirm sudo
#PASSWORD="hello"
# XXX do more stuff here XXX
#passwd

# ---==[ Build initrd ]==------------------------------------------------------
#pacman -Syy  # update things?
#pacman -S --noconfirm lvm2  # already in base
#pacman -S --noconfirm cryptsetup  # already in base
# XXX do more stuff here XXX
# /etc/mkinitcpio.conf
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
# HOOKS="... encrypt ... filesystems ..."
#mkinitcpio -p linux

# ---==[ Set up boot loader stuff ]==------------------------------------------
# If UEFI is enabled
# XXX do more stuff here XXX
# ls /sys/firmware/efi/efivars
pacman -S --noconfirm grub
grub-install --target=i386-pc "${BOOTDEVICE}"
grub-mkconfig -o /boot/grub/grub.cfg
