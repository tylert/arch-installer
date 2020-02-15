#!/usr/bin/env bash

# Kick off the install procedure from the Arch Linux LiveCD

set -xe

# -----------------------------------------------------------------------------
timedatectl set-ntp true

# ---==[ Partition, format and mount the OS drive ]==--------------------------
if [ -z "${DRIVE}" ]; then
    DRIVE='/dev/sda'
fi

dd if=/dev/zero of="${DRIVE}" bs=1M count=8
echo 'label: gpt' | sfdisk "${DRIVE}"
sfdisk "${DRIVE}" << EOF
,256M,U
,20G,S
,
EOF
mkfs.vfat -F32 ${DRIVE}1
mkswap ${DRIVE}2
mkfs.btrfs ${DRIVE}3

# ---==[ Install the base OS stuff ]==-----------------------------------------
if [ -z "${MOUNT_POINT}" ]; then
    MOUNT_POINT='/mnt'
fi

swapon ${DRIVE}2
exit
pacstrap ${MOUNT_POINT} base linux linux-firmware

# ---==[ Build the fstab for the new system ]==--------------------------------
genfstab -p -t UUID "${MOUNT_POINT}" >> "${MOUNT_POINT}/etc/fstab"

# -----------------------------------------------------------------------------
if [ -z "${TIMEZONE}" ]; then
    TIMEZONE='UTC'
else
if [ -z "${LOCALE}" ]; then
    LOCALE='en_CA'
fi
if [ -z "${ENCODING}" ]; then
    ENCODING='UTF-8'
fi
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi
if [ -z "${HOSTNAME}" ]; then
    HOSTNAME='cuckoo'
fi
if [ -z "${DOMAIN}" ]; then
    DOMAIN='localdomain'
fi

cp configure_x86.sh "${MOUNT_POINT}/tmp/configure_x86.sh"
arch-chroot "${MOUNT_POINT}" \
    DOMAIN="${DOMAIN}" \
    DRIVE="${DRIVE}" \
    ENCODING="${ENCODING}" \
    HOSTNAME="${HOSTNAME}" \
    KEYMAP="${KEYMAP}" \
    LOCALE="${LOCALE}" \
    TIMEZONE="${TIMEZONE}" \
    /tmp/configure_x86.sh

# -----------------------------------------------------------------------------
# reboot
