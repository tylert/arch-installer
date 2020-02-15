#!/usr/bin/env bash

# Kick off the install procedure from the archiso CD

# Pre-flight checklist:
# 1.  Network is up.
# 2.  OS drive is attached/available.

set -xe

# -----------------------------------------------------------------------------
timedatectl set-ntp true

# ---==[ Partition, format and mount the OS drive ]==--------------------------
if [ -z "${DRIVE}" ]; then
    DRIVE='/dev/sda'
fi
if [ -z "${MOUNT_POINT}" ]; then
    MOUNT_POINT='/mnt'
fi
dd if=/dev/zero of="${DRIVE}" bs=1M count=8
sfdisk "${DRIVE}" << EOF
,
EOF
# XXX do more stuff here XXX

# ---==[ Install the base OS stuff ]==-----------------------------------------
pacstrap ${MOUNT_POINT} base linux linux-firmware

# ---==[ Build the fstab for the new system ]==--------------------------------
genfstab -p -t UUID "${MOUNT_POINT}" >> "${MOUNT_POINT}/etc/fstab"

# -----------------------------------------------------------------------------
cp configure.sh ${MOUNT_POINT}/tmp/configure.sh
arch-chroot ${MOUNT_POINT} \
    DOMAIN="${DOMAIN}" \
    DRIVE="${DRIVE}" \
    ENCODING="${ENCODING}" \
    HOSTNAME="${HOSTNAME}" \
    KEYMAP="${KEYMAP}" \
    LOCALE="${LOCALE}" \
    TIMEZONE="${TIMEZONE}" \
    /tmp/configure.sh

# -----------------------------------------------------------------------------
# reboot
