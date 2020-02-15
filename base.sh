#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

set -xe

# Check network and synchronize clock
timedatectl set-ntp true

# ---==[ Partition, format and mount the OS drive ]==--------------------------
TARGET='/mnt'
# XXX do more stuff here XXX

# -----------------------------------------------------------------------------
pacstrap ${TARGET} base linux linux-firmware btrfs-progs wireguard-arch wireguard-tools

# -----------------------------------------------------------------------------
genfstab -p -t UUID ${TARGET} >> ${TARGET}/etc/fstab

# -----------------------------------------------------------------------------
# Select mirror and do base install
# cp base_chroot.sh ${TARGET}/root/base_chroot.sh

# -----------------------------------------------------------------------------
arch-chroot ${TARGET}
# arch-chroot ${TARGET} \
#     BOOTDEVICE='/dev/sda' \
#     DOMAIN='localdomain' \
#     ENCODING='UTF-8' \
#     HOSTNAME='cuckoo' \
#     KEYMAP='us' \
#     LOCALE='en_CA' \
#     TIMEZONE='Canada/Eastern' \
#     /root/base_chroot.sh

reboot
