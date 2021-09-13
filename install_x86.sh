#!/usr/bin/env bash

# Kick off the full install procedure and then configure the chroot

# Install assumptions:
# - no UEFI
# - SSD >= swap size + OS requirements
# - swap size is RAM + "a bit" (hibernate)
# - unencrypted root
# - unencrypted swap
# - btrfs root
# - boot is inside root

set -xe

# ---==[ Make sure the keyboard is available ]==-------------------------------
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi

# Look in /usr/share/kbd/keymaps for valid keymap names
loadkeys "${KEYMAP}"

# ---==[ Repartition and format the OS drive ]==-------------------------------
if [ -z "${DRIVE}" ]; then
    DRIVE='/dev/sda'
fi

# XXX FIXME TODO  Calculate size of swap partition based on amount of RAM

dd if=/dev/zero of="${DRIVE}" bs=1M count=8
echo 'label: dos' | sfdisk --force --no-reread "${DRIVE}"
sfdisk --force --no-reread "${DRIVE}" << EOF
,17G,S
,
EOF
partx "${DRIVE}"
# might have to "dmsetup remove /dev/mapper/foo"

mkswap "${DRIVE}1"
mkfs.btrfs --force --label OS "${DRIVE}2"

# ---==[ Create subvolumes and mount subordinate partitions ]==----------------
if [ -z "${MOUNT}" ]; then
    MOUNT='/mnt'
fi

mount "${DRIVE}2" "${MOUNT}" --options subvolid=5
btrfs subvolume create "${MOUNT}/@"
umount "${MOUNT}"
mount "${DRIVE}2" "${MOUNT}" --options subvol=@

swapon "${DRIVE}1"

# ---==[ Install the OS and build the fstab file ]==---------------------------
timedatectl set-ntp true
pacstrap "${MOUNT}" base btrfs-progs linux linux-firmware
# basestrap "${MOUNT}" base

cat << EOF > "${MOUNT}/etc/fstab"
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF
genfstab -p -t UUID "${MOUNT}" >> "${MOUNT}/etc/fstab"

# ---==[ Configure the new system ]==------------------------------------------
cp configure_x86.sh "${MOUNT}/root/"
arch-chroot "${MOUNT}" /root/configure_x86.sh "${DRIVE}"
rm "${MOUNT}/root/configure_x86.sh"

# ---==[ Unmount everything ]==------------------------------------------------
swapoff "${DRIVE}2"
umount "${MOUNT}/boot"
umount "${MOUNT}"
