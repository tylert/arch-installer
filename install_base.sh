#!/usr/bin/env bash

# https://wiki.archlinux.org/index.php/Installation_guide

# Check network
# XXX do stuff here XXX

# Set time and date
timedatectl set-ntp true

# Set up partitions
BOOT_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/mapper/primary-root"
# XXX do stuff here XXX

# Mount partitions
TARGET="/mnt"
mount ${ROOT_PARTITION} ${TARGET}
mkdir ${TARGET}/boot
mount ${BOOT_PARTITION} ${TARGET}/boot

# Package install
# XXX do stuff here XXX
# Select mirror
pacstrap ${TARGET} base

# Generate fstab
genfstab -U ${TARGET} >> ${TARGET}/etc/fstab

# Enter chroot
arch-chroot ${TARGET}

# Configure timezone
TIMEZONE="Canada/Eastern"
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Set system clock to UTC
hwclock --systohc

# Set locale
LOCALE="en_CA.UTF-8"
ENCODING="UTF-8"
sed -i "/^#${LOCALE} ${ENCODING} /s/^#//" /etc/locale.gen
echo "LANG=${LOCALE}" > /etc/locale.conf
locale-gen

# Set keyboard layout
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
HOSTNAME="buttercup"
echo "${HOSTNAME}" > /etc/hostname

# Configure hosts
cat << EOF > /etc/hosts
127.0.0.1  localhost.localdomain  localhost
::1  localhost.localdomain  localhost
127.0.1.1  ${HOSTNAME}.localdomain  ${HOSTNAME}
EOF

# Example /etc/hosts from Debian
# ---
#127.0.0.1  localhost
#127.0.1.1  ${HOSTNAME}.${DOMAIN}  ${HOSTNAME}
#
## The following lines are desirable for IPv6 capable hosts
#::1     localhost ip6-localhost ip6-loopback
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
# ---

# Set up networking junk
# XXX do stuff here XXX

# Build initrd
yes | pacman -S lvm2
#yes | pacman -S cryptsetup
# XXX do stuff here XXX
# /etc/mkinitcpio.conf
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
mkinitcpio -p linux

# Set root password
#PASSWORD="hello"
#passwd
# XXX do stuff here XXX

# Boot loader stuff
# If UEFI is enabled
# ls /sys/firmware/efi/efivars
yes | pacman -S grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
# XXX do stuff here XXX

# Exit chroot
exit

# Reboot
reboot
