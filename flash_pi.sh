#!/usr/bin/env bash

# This is a script for flashing a microSD card for a Raspberry Pi as per
# the instructions found at:
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
# https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
# https://archlinuxarm.org/platforms/armv6/raspberry-pi

set -e

drive='/dev/mmcblk0'  # uSD
first_partition="${drive}p1"
second_partition="${drive}p2"
date='latest'
# root_tarball_remote='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz'
# root_tarball_remote='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz'
# root_tarball_remote='http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz'
root_tarball_local="/tmp/archlinux-${date}-rpi-aarch64.tar.gz"
root_filesystem_type='ext4'
first_mount_point="$(mktemp --dry-run)"  # unsafeish
second_mount_point="$(mktemp --dry-run)"  # unsafeish

# Fetch the root filesystem tarball
# wget "${root_tarball_remote}" --continue --output-document="${root_tarball_local}"

# Format the drive
dd if=/dev/zero of="${drive}" bs=1M count=8
sfdisk --force --no-reread "${drive}" << EOF
,200M
,
EOF
mkfs.vfat -n BOOT "${first_partition}"
if [ 'btrfs' = "${root_filesystem_type}" ]; then
    mkfs.btrfs --force --label OS "${second_partition}"
else
    mkfs.ext4 -F -L OS "${second_partition}"
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose "${first_mount_point}"
mkdir --parents --verbose "${second_mount_point}"
mount "${first_partition}" "${first_mount_point}"
mount "${second_partition}" "${second_mount_point}"

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory="${second_mount_point}" \
    --extract --verbose --gunzip --file="${root_tarball_local}"

# Fix up the boot magic
sed --in-place 's/mmcblk0/mmcblk1/g' "${second_mount_point}/etc/fstab"
cp --preserve=mode,ownership,timestamps --recursive --verbose "${second_mount_point}/boot/"* "${first_mount_point}"
rm --force --recursive --verbose "${second_mount_point}/boot/"*

# Remove the need to perform manual steps after installation
# You need the appropriate binaries in order to run a arm64 chroot on x86_64
# On Debian, "apt-get install qemu qemu-user-static binfmt-support"
# XXX FIXME TODO Get this part working to reduce the dumb, non-automated junk
# chroot "${first_mount_point}" && \
#     pacman-key --init && \
#     pacman-key --populate archlinuxarm && \
#     pacman --sysupgrade --sync --refresh --noconfirm sudo && \
#     echo "alarm ALL=(ALL) ALL" > /etc/sudoers.d/alarm

# Clean up afterwards
umount "${first_mount_point}"
umount "${second_mount_point}"
rm --force --recursive --verbose "${first_mount_point}"
rm --force --recursive --verbose "${second_mount_point}"
sync
