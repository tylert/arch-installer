#!/usr/bin/env bash

# This is a script for flashing a microSD card for a Raspberry Pi as per
# the instructions found at:
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
# https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
# https://archlinuxarm.org/platforms/armv6/raspberry-pi

set -e

drive=/dev/mmcblk0
first_partition="${drive}p1"
second_partition="${drive}p2"
date="$(date +%Y-%m-%d)"  # latest
root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
# root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
# root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
root_tarball_local="/tmp/ArchLinuxARM-rpi-3-${date}.tar.gz"
root_filesystem_type=ext4
mount_point="$(mktemp --dry-run)"  # unsafeish

# Fetch the root filesystem tarball
wget "${root_tarball_remote}" --continue --output-document="${root_tarball_local}"

# Format the drive
dd if=/dev/zero of="${drive}" bs=1M count=8
sfdisk "${drive}" << EOF
,100M
,
EOF
mkfs.vfat -n boot "${first_partition}"
if [ "${root_filesystem_type}" = 'btrfs' ]; then
    mkfs.btrfs --force --label os "${second_partition}"
else
    mkfs.ext4 -F -L os "${second_partition}"
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose "${mount_point}"
mount "${second_partition}" "${mount_point}"
if [ "${root_filesystem_type}" = 'btrfs' ]; then
    # XXX FIXME TODO Get btrfs root working
    echo "btrfs booting doesn't work at the moment"
    exit 2
fi
mkdir --parents --verbose ${mount_point}/boot
mount "${first_partition}" ${mount_point}/boot

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory="${mount_point}" \
    --extract --verbose --gunzip --file="${root_tarball_local}"

# Remove the need to perform manual steps after installation
# You need the appropriate binaries in order to run a arm64 chroot on x86_64
# On Debian, "apt-get install qemu qemu-user-static binfmt-support"
# XXX FIXME TODO Get this part working to reduce the dumb, non-automated junk
# chroot "${mount_point}" pacman-key --init && \
#     pacman-key --populate archlinuxarm && \
#     pacman -Syu --noconfirm sudo && \
#     echo "alarm ALL=(ALL) ALL" > /etc/sudoers.d/alarm

# Clean up afterwards
umount ${mount_point}/boot
umount "${mount_point}"
rm --recursive --force "${mount_point}"
sync
