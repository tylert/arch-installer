#!/usr/bin/env bash

# Do the things that must be done inside the arch-chroot

set -xe

# ---==[ Set up the timezone and system clock ]==------------------------------
if [ -z "${TIMEZONE}" ]; then
    TIMEZONE='UTC'
else

ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc --utc

# ---==[ Set up the system language, locale and keymap ]==---------------------
if [ -z "${LOCALE}" ]; then
    LOCALE='en_CA'
fi
if [ -z "${ENCODING}" ]; then
    ENCODING='UTF-8'
fi
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi

sed -i "/^#${LOCALE}.${ENCODING} ${ENCODING} /s/^#//" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}.${ENCODING}" > /etc/locale.conf  # create
echo "LANGUAGE=${LOCALE}" >> /etc/locale.conf
echo "LC_ALL=C" >> /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# ---==[ Set up the new hostname and hosts file ]==----------------------------
if [ -z "${HOSTNAME}" ]; then
    HOSTNAME='cuckoo'
fi
if [ -z "${DOMAIN}" ]; then
    DOMAIN='localdomain'
fi

echo "${HOSTNAME}" > /etc/hostname
echo "127.0.0.1  localhost" >> /etc/hosts  # append
echo "127.0.1.1  ${HOSTNAME} ${HOSTNAME}.${DOMAIN}" >> /etc/hosts
echo "::1  localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1  ip6-allnodes" >> /etc/hosts
echo "ff02::2  ip6-allrouters" >> /etc/hosts

# ---==[ Set up networking ]==-------------------------------------------------
pacman --sync --noconfirm dhcpcd openssh wireguard-arch wireguard-tools
systemctl enable dhcpcd
systemctl enable sshd.service

# ---==[ Set up a base user and group ]==--------------------------------------
pacman --sync --noconfirm sudo
# echo "${USERNAME} ALL=(ALL) ALL" > "/etc/sudoers.d/${USERNAME}"
# XXX do more stuff here XXX

# ---==[ Build initrd ]==------------------------------------------------------
pacman --sync --noconfirm btrfs-progs
# /etc/mkinitcpio.conf
# XXX do more stuff here XXX
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
# HOOKS="... encrypt ... filesystems ..."
mkinitcpio -p linux

# ---==[ Set up boot loader stuff ]==------------------------------------------
# If UEFI is enabled
# XXX do more stuff here XXX
# ls /sys/firmware/efi/efivars
pacman --sync --noconfirm grub
# grub-install --target=i386-pc "${DRIVE}"
# grub-mkconfig -o /boot/grub/grub.cfg
