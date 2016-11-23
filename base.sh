#!/usr/bin/env bash

# https://wiki.archlinux.org/index.php/Installation_guide
# https://github.com/bianjp/archlinux-installer

# Check network and synchronize clock
# XXX do more stuff here XXX
timedatectl set-ntp true

# Set up partitions and mount them
ROOT_PARTITION="/dev/mapper/primary-root"
BOOT_PARTITION="/dev/sda1"
# XXX do more stuff here XXX
TARGET="/mnt"
mount ${ROOT_PARTITION} ${TARGET}
mkdir ${TARGET}/boot
mount ${BOOT_PARTITION} ${TARGET}/boot

# Select mirror
# XXX do more stuff here XXX

# Base install
pacstrap ${TARGET} base

# Generate fstab
genfstab -U -p ${TARGET} >> ${TARGET}/etc/fstab
cp chroot.sh ${TARGET}/root/base_chroot.sh

# Enter chroot
arch-chroot ${TARGET} \
  LOCALE="en_CA" ENCODING="UTF-8" KEYMAP="us" \
  TIMEZONE="Canada/Eastern" \
  HOSTNAME="wowbagger" \
  BOOTDEVICE="/dev/sda" \
  /root/base_chroot.sh

reboot
