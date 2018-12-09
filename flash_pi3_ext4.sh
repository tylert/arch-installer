#!/usr/bin/env bash

# This is a script for flashing a microSD card for an Raspberry Pi 2/3 as per
# the instructions found at:
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
# https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2

drive=/dev/mmcblk0
first_partition=${drive}p1
second_partition=${drive}p2
date=$(date +%Y-%m-%d)  # latest
root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
root_tarball_local=/tmp/ArchLinuxARM-rpi-2-${date}.tar.gz
mount_point=$(mktemp --dry-run)  # unsafeish

# Fetch the root filesystem tarball
wget ${root_tarball_remote} --continue --output-document=${root_tarball_local}

# Format the drive
dd if=/dev/zero of=${drive} bs=1M count=8
sfdisk ${drive} << EOF
,100M
,
EOF
mkfs.vfat --force ${first_partition}
mkfs.ext4 -L OS ${second_partition}

# Mount the drive and create the necessary locations
mkdir --parents --verbose ${mount_point}
mount ${second_partition} ${mount_point}
mkdir --parents --verbose ${mount_point}/boot
mount ${first_partition} ${mount_point}/boot

# Extract the root filesystem tarball
tar --warning=no-unknown-keyword --directory=${mount_point} \
    --extract --verbose --gunzip --file=${root_tarball_local}

# Clean up afterwards
umount ${mount_point}/boot
umount ${mount_point}
rm --recursive --force ${mount_point}
sync
