#!/usr/bin/env bash

# This is a script for flashing a microSD card for an Odroid HC2 as per the
# instructions found at:
# https://archlinuxarm.org/platforms/armv7/samsung/odroid-hc2

set -e

drive='/dev/mmcblk0'  # uSD
first_partition="${drive}p1"
date='latest'
# root_tarball_remote='http://os.archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz'
root_tarball_local="/tmp/archlinux-${date}-odroid-xu3.tar.gz"
root_filesystem_type='ext4'
first_mount_point="$(mktemp --dry-run)"  # unsafeish

# Fetch the root filesystem tarball
# wget "${root_tarball_remote}" --continue --output-document="${root_tarball_local}"

# Format the drive
dd if=/dev/zero of="${drive}" bs=1M count=8
sfdisk --force --no-reread "${drive}" << EOF
4096
EOF
if [ 'btrfs' = "${root_filesystem_type}" ]; then
    mkfs.btrfs --force --label OS "${first_partition}"
else
    mkfs.ext4 -F -L OS "${first_partition}"
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose "${first_mount_point}"
mount "${first_partition}" "${first_mount_point}"

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory="${first_mount_point}" \
    --extract --verbose --gunzip --file="${root_tarball_local}"

# Fix up the boot magic
pushd "${first_mount_point}/boot"
sh sd_fusing.sh "${drive}"
popd

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
rm --force --recursive --verbose "${first_mount_point}"
sync
