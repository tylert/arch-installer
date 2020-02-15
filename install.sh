#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

set -xe

# Check network and synchronize clock
timedatectl set-ntp true

# ---==[ Partition, format and mount the OS drive ]==--------------------------
if [ -z "${MOUNT_POINT}" ]; then
    MOUNT_POINT='/mnt'
fi
# XXX do more stuff here XXX

# ---==[ Install the base OS stuff ]==-----------------------------------------
pacstrap ${MOUNT_POINT} base linux linux-firmware

# -----------------------------------------------------------------------------
genfstab -p -t UUID ${MOUNT_POINT} >> ${MOUNT_POINT}/etc/fstab

# -----------------------------------------------------------------------------
# Select mirror and do base install

# -----------------------------------------------------------------------------
cp setup.sh ${MOUNT_POINT}/tmp/setup.sh
arch-chroot ${MOUNT_POINT} \
    BOOTDEVICE='/dev/sda' \
    /tmp/setup.sh

# reboot
