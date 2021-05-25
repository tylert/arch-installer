#!/usr/bin/env bash

# This is a script for flashing a microSD/eMMC card for an Odroid C2 as per the
# instructions found at:
# https://archlinuxarm.org/platforms/armv8/amlogic/odroid-c2

set -e

drive='/dev/sdb'  # eMMC
first_partition="${drive}1"
date='latest'
# root_tarball_remote='http://os.archlinuxarm.org/os/ArchLinuxARM-odroid-c2-latest.tar.gz'
root_tarball_local="/tmp/archlinux-${date}-odroid-c2.tar.gz"
root_filesystem_type='ext4'
mount_point="$(mktemp --dry-run)"  # unsafeish

# Fetch the root filesystem tarball
# wget "${root_tarball_remote}" --continue --output-document="${root_tarball_local}"

# Format the drive
dd if=/dev/zero of="${drive}" bs=1M count=8
sfdisk --force "${drive}" << EOF
,
EOF
if [ 'btrfs' = "${root_filesystem_type}" ]; then
    mkfs.btrfs --force --label OS "${first_partition}"
else
    mkfs.ext4 -O ^metadata_csum,^64bit -F -L OS "${first_partition}"
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose "${mount_point}"
mount "${first_partition}" "${mount_point}"
if [ 'btrfs' = "${root_filesystem_type}" ]; then
    # XXX FIXME TODO Get btrfs root working
    echo "btrfs booting doesn't work at the moment"
    exit 2
fi

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory="${mount_point}" \
    --extract --verbose --gunzip --file="${root_tarball_local}"

# Remove the need to perform manual steps after installation
# You need the appropriate binaries in order to run a arm64 chroot on x86_64
# On Debian, "apt-get install qemu qemu-user-static binfmt-support"
# XXX FIXME TODO Get this part working to reduce the dumb, non-automated junk
# chroot "${mount_point}" && \
#     pacman-key --init && \
#     pacman-key --populate archlinuxarm && \
#     pacman --sysupgrade --sync --refresh --noconfirm sudo && \
#     echo "alarm ALL=(ALL) ALL" > /etc/sudoers.d/alarm

# Flash the boot sector
pushd "${mount_point}/boot"
sh sd_fusing.sh "${drive}"
popd

# Clean up afterwards
umount "${mount_point}"
rm --recursive --force "${mount_point}"
sync
