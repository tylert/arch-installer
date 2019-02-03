#!/usr/bin/env bash

# This is a script for flashing a microSD card for an Raspberry Pi 2/3 as per
# the instructions found at:
# https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
# https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2

drive=/dev/mmcblk0
first_partition=${drive}p1
second_partition=${drive}p2
date=$(date +%Y-%m-%d)  # latest
root_tarball_remote=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
root_tarball_local=/tmp/ArchLinuxARM-rpi-3-${date}.tar.gz
root_filesystem_type=ext4
mount_point=$(mktemp --dry-run)  # unsafeish

# Fetch the root filesystem tarball
wget ${root_tarball_remote} --continue --output-document=${root_tarball_local}

# Format the drive
dd if=/dev/zero of=${drive} bs=1M count=8
sfdisk ${drive} << EOF
,100M
,
EOF
mkfs.vfat ${first_partition}
if [ ${root_filesystem_type} = btrfroot_filesystem_type ]; then
    mkfs.btrfs --force --label OS ${second_partition}
else
    mkfs.ext4 -L OS ${second_partition}
fi

# Mount the drive and create the necessary locations
mkdir --parents --verbose ${mount_point}
mount ${second_partition} ${mount_point}
if [ ${root_filesystem_type} = btrfs ]; then
    mkdir --parents --verbose ${mount_point}/_snapshot
    mkdir --parents --verbose ${mount_point}/_current
    btrfs subvolume create ${mount_point}/_current/slash
    umount ${mount_point}
    mount --options subvol=_current/slash ${second_partition} ${mount_point}
fi
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
