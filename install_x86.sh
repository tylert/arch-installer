#!/usr/bin/env bash

# Kick off the install procedure from the Arch Linux LiveCD

# Install assumptions:
# - UEFI
# - SSD >= (2 * RAM) + 1 GB + n GB
# - swap is RAM + "a bit" (hibernate)
# - unencrypted root
# - unencrypted swap
# - btrfs root
# - boot is inside root

set -xe

# -----------------------------------------------------------------------------
timedatectl set-ntp true

# ---==[ Repartition and format the OS drive ]==-------------------------------
if [ -z "${DRIVE}" ]; then
    DRIVE='/dev/sda'
fi

dd if=/dev/zero of="${DRIVE}" bs=1M count=8
echo 'label: gpt' | sfdisk "${DRIVE}"
sfdisk "${DRIVE}" << EOF
,256M,U
,20G,S
,
EOF

mkfs.vfat -F32 "${DRIVE}1"
mkswap "${DRIVE}2"
mkfs.btrfs --force --label os "${DRIVE}3"

# ---==[ Create subvolumes and mount subordinate partitions ]==----------------
if [ -z "${MOUNT}" ]; then
    MOUNT='/mnt'
fi

mount "${DRIVE}3" "${MOUNT}" --options defaults,ssd,discard
btrfs subvolume create "${MOUNT}/@"
btrfs subvolume create "${MOUNT}/@snapshot"
btrfs subvolume set-default 256 "${MOUNT}"
umount "${MOUNT}"
mount "${DRIVE}3" "${MOUNT}" --options defaults,ssd,discard,subvol=@

mkdir --parents "${MOUNT}/boot/EFI"
mount "${DRIVE}1" "${MOUNT}/boot/EFI"
swapon "${DRIVE}2"
mkdir --parents "${MOUNT}/.snapshot"
mount "${DRIVE}3" "${MOUNT}/.snapshot" --options defaults,ssd,discard,subvol=@snapshot

# ---==[ Install the OS and build the fstab file ]==---------------------------
pacstrap "${MOUNT}" base linux linux-firmware

echo "# Static information about the filesystems." > "${MOUNT}/etc/fstab"
echo "# See fstab(5) for details." >> "${MOUNT}/etc/fstab"
echo "" >> "${MOUNT}/etc/fstab"
echo "# <file system> <dir> <type> <options> <dump> <pass>" >> "${MOUNT}/etc/fstab"
genfstab -p -t UUID "${MOUNT}" >> "${MOUNT}/etc/fstab"

# ---==[ Configure the new system ]==------------------------------------------
cp configure_x86.sh "${MOUNT}/root/"
arch-chroot "${MOUNT}" /root/configure_x86.sh

# -----------------------------------------------------------------------------
# reboot
