#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

set -xe

# Check network and synchronize clock
timedatectl set-ntp true

# Set up swap and partitions and mounts
TARGET="/mnt/arch"
# XXX do more stuff here XXX

pacstrap ${TARGET} base linux linux-firmware btrfs-progs wireguard-arch wireguard-tools

# Select mirror and do base install
# cp base_chroot.sh ${TARGET}/root/base_chroot.sh

genfstab -U -p ${TARGET} >> ${TARGET}/etc/fstab

# Enter chroot
arch-chroot ${TARGET}
# arch-chroot ${TARGET} \
#     BOOTDEVICE="/dev/sda" \
#     LOCALE="en_CA" ENCODING="UTF-8" KEYMAP="us" TIMEZONE="Canada/Eastern" \
#     HOSTNAME="cuckoo" DOMAIN="localdomain" \
#     /root/base_chroot.sh

reboot
