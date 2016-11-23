#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

set -xe

# Check network and synchronize clock
# XXX do more stuff here XXX
timedatectl set-ntp true

# Set up swap and partitions and mount everything
ROOT_PARTITION="/dev/mapper/primary-root"
BOOT_PARTITION="/dev/sda1"
TARGET="/mnt"
# XXX do more stuff here XXX
mount ${ROOT_PARTITION} ${TARGET}
mkdir ${TARGET}/boot
mount ${BOOT_PARTITION} ${TARGET}/boot

# Select mirror and do base install
# XXX do more stuff here XXX
pacstrap ${TARGET} base base-devel

# Generate fstab and prepare chroot
genfstab -U -p ${TARGET} >> ${TARGET}/etc/fstab
cp base_chroot.sh ${TARGET}/root/base_chroot.sh

# Enter chroot
arch-chroot ${TARGET} \
    BOOTDEVICE="/dev/sda" \
    LOCALE="en_CA" ENCODING="UTF-8" KEYMAP="us" TIMEZONE="Canada/Eastern" \
    HOSTNAME="cuckoo" DOMAIN="localdomain" \
    /root/base_chroot.sh

reboot
