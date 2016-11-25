#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

set -xe

# Check network and synchronize clock
# XXX do more stuff here XXX
timedatectl set-ntp true

# Set up swap and partitions and mounts
BOOT_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/mapper/primary-root"
SWAP_PARTITION="/dev/mapper/primary-swap_1"
TARGET="/mnt"
# XXX do more stuff here XXX
mount ${ROOT_PARTITION} ${TARGET}
mkdir ${TARGET}/boot
mount ${BOOT_PARTITION} ${TARGET}/boot
mkdir ${TARGET}/etc
genfstab -U -p ${TARGET} >> ${TARGET}/etc/fstab

# Select mirror and do base install
mkdir ${TARGET}/root
cp base_chroot.sh ${TARGET}/root/base_chroot.sh
# XXX do more stuff here XXX
pacstrap ${TARGET} base base-devel

# Enter chroot
arch-chroot ${TARGET} \
    BOOTDEVICE="/dev/sda" \
    LOCALE="en_CA" ENCODING="UTF-8" KEYMAP="us" TIMEZONE="Canada/Eastern" \
    HOSTNAME="cuckoo" DOMAIN="localdomain" \
    /root/base_chroot.sh

reboot
