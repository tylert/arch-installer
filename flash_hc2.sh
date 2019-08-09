#!/usr/bin/env bash

# This is a script for flashing a microSD card for an Odroid HC2 as per the
# instructions found at:
# https://archlinuxarm.org/platforms/armv7/samsung/odroid-hc2

drive=/dev/mmcblk0
first_partition="${drive}p1"
date="$(date +%Y-%m-%d)"  # latest
root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz
root_tarball_local="/tmp/ArchLinuxARM-odroid-xu3-${date}.tar.gz"
root_filesystem_type=ext4
mount_point="$(mktemp --dry-run)"  # unsafeish

# Fetch the root filesystem tarball
wget "${root_tarball_remote}" --continue --output-document="${root_tarball_local}"

# Format the drive
dd if=/dev/zero of="${drive}" bs=1M count=8
sfdisk "${drive}" << EOF
4096
EOF
if [ "${root_filesystem_type}" = 'btrfs' ]; then
    mkfs.btrfs --force --label os "${first_partition}"
else
    mkfs.ext4 -L os "${first_partition}"
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose "${mount_point}"
mount "${first_partition}" "${mount_point}"
if [ "${root_filesystem_type}" = 'btrfs' ]; then
    # XXX FIXME TODO Get btrfs root working
    echo "btrfs booting doesn't work at the moment"
    exit 2
fi

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory="${mount_point}" \
    --extract --verbose --gunzip --file="${root_tarball_local}"

# Remove the need to perform manual steps after installation
# XXX FIXME TODO Get arm chroot working on x86_64
# chroot "${mount_point}"
# pacman-key --init
# pacman-key --populate archlinuxarm
# exit

# Flash the boot sector
pushd ${mount_point}/boot
sh sd_fusing.sh "${drive}"
popd

# Clean up afterwards
umount "${mount_point}"
rm --recursive --force "${mount_point}"
sync
