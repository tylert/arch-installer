#!/usr/bin/env bash

# https://wiki.archlinux.org/index.php/Installation_guide
# https://github.com/bianjp/archlinux-installer

# Check network and synchronize clock
# XXX do stuff here XXX
timedatectl set-ntp true

# Set up partitions and mount them
ROOT_PARTITION="/dev/mapper/primary-root"
BOOT_PARTITION="/dev/sda1"
# XXX do stuff here XXX
TARGET="/mnt"
mount ${ROOT_PARTITION} ${TARGET}
mkdir ${TARGET}/boot
mount ${BOOT_PARTITION} ${TARGET}/boot

# Select mirror
# XXX do stuff here XXX

# Base install
pacstrap ${TARGET} base

# Generate fstab
genfstab -U -p ${TARGET} >> ${TARGET}/etc/fstab

# Enter chroot
arch-chroot ${TARGET}  # call script?

# ---==[ START OF CHROOT ]==---------------------------------------------------

# Configure timezone and clock
TIMEZONE="Canada/Eastern"
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc --utc

# Set locale and key layout
sed -i "/^#en_CA.UTF-8 UTF-8 /s/^#//" /etc/locale.gen
locale-gen
echo "LANG=en_CA.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname and configure hosts
HOSTNAME="buttercup"
echo "${HOSTNAME}" > /etc/hostname
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
#pacman -S --noconfirm dhclient

# Set up users and groups
#PASSWORD="hello"
# XXX do stuff here XXX
#passwd

# Build initrd
#pacman -Syy
#pacman -S --noconfirm lvm2
#pacman -S --noconfirm cryptsetup
# XXX do stuff here XXX
# /etc/mkinitcpio.conf
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
#mkinitcpio -p linux

# Boot loader stuff
# If UEFI is enabled
# ls /sys/firmware/efi/efivars
#pacman -S --noconfirm grub
#grub-install --target=i386-pc /dev/sda
#grub-mkconfig -o /boot/grub/grub.cfg
# XXX do stuff here XXX

# ---==[ END OF CHROOT ]==-----------------------------------------------------

# Exit chroot and reboot
#exit
#reboot
