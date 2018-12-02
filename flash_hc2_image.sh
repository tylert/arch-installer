#!/usr/bin/env bash

# This is a script for flashing a microSD card for an Odroid HC2 as per the
# instructions found at:
# https://archlinuxarm.org/platforms/armv7/samsung/odroid-hc2

drive=/dev/mmcblk0
first_partition=${drive}p1
date=latest  # $(date +%Y-%m-%d)
root_tarball=/tmp/ArchLinuxARM-odroid-xu3-${date}.tar.gz
mount_point=$(mktemp --dry-run)  # unsafeish

# Fetch the tarball
wget http://os.archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz \
    --continue --output-document=${root_tarball}

# Format the drive
dd if=/dev/zero of=${drive} bs=1M count=8
sfdisk ${drive} << EOF
4096
EOF
mkfs.btrfs --force --label OS ${first_partition}  # XXX btrfs

# Mount the drive and create the subvolume and snapshots location
mkdir --parents --verbose ${mount_point}
mount ${first_partition} ${mount_point}
mkdir --parents --verbose ${mount_point}/_snapshot  # XXX btrfs
mkdir --parents --verbose ${mount_point}/_current  # XXX btrfs
btrfs subvolume create ${mount_point}/_current/slash  # XXX btrfs

# Remount the subvolume and extract the tarball
umount ${mount_point}
mount --options subvol=_current/slash ${first_partition} ${mount_point}  # XXX btrfs
tar --warning=no-unknown-keyword --directory=${mount_point} \
    --extract --verbose --gunzip --file=${root_tarball}

# Flash the boot sector
pushd ${mount_point}/boot
sh sd_fusing.sh ${drive}
popd

# Clean up afterwards
umount ${mount_point}
rm --recursive --force ${mount_point}
sync