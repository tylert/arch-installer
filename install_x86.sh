#!/usr/bin/env bash

# Kick off the full install procedure and then configure the chroot

set -xe

# ---==[ Configure the system clock via NTP ]==--------------------------------
timedatectl set-ntp true

# ---==[ Install the OS and build the fstab file ]==---------------------------
if [ -z "${DRIVE}" ]; then
    echo 'You must provide the DRIVE environment variable!!!'
    exit 1
fi
if [ -z "${MOUNT}" ]; then
    MOUNT='/mnt'
fi

pacstrap "${MOUNT}" base linux linux-firmware

cat << EOF > "${MOUNT}/etc/fstab"
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF
genfstab -p -t UUID "${MOUNT}" >> "${MOUNT}/etc/fstab"

# ---==[ Configure the new system ]==------------------------------------------
cp configure_x86.sh "${MOUNT}/root/"
arch-chroot "${MOUNT}" /root/configure_x86.sh
rm "${MOUNT}/root/configure_x86.sh"

# ---==[-----------------------------------------------------------------------
# reboot
