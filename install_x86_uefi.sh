#!/usr/bin/env bash

# Kick off the full install procedure and then configure the chroot

# Install assumptions:
# - UEFI
# - SSD >= (2 * RAM) + 1 GB + n GB
# - swap is RAM + "a bit" (hibernate)
# - unencrypted root
# - unencrypted swap
# - btrfs root
# - boot is inside root

set -xe

# ---==[ Make sure the keyboard is available ]==-------------------------------
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi

loadkeys "${KEYMAP}"
# look in /usr/share/kbd/keymaps

# ---==[ Repartition and format the OS drive ]==-------------------------------
if [ -z "${DRIVE}" ]; then
    DRIVE='/dev/sda'
fi

dd if=/dev/zero of="${DRIVE}" bs=1M count=8
echo 'label: gpt' | sfdisk --force "${DRIVE}"
sfdisk --force "${DRIVE}" << EOF
,256M,U
,20G,S
,
EOF
partx "${DRIVE}"
# might have to "dmsetup remove /dev/mapper/foo"

mkfs.vfat -F 32 "${DRIVE}1"
mkswap "${DRIVE}2"
mkfs.btrfs --force --label os "${DRIVE}3"

# ---==[ Create subvolumes and mount subordinate partitions ]==----------------
if [ -z "${MOUNT}" ]; then
    MOUNT='/mnt'
fi

mount "${DRIVE}3" "${MOUNT}" --options subvolid=5
btrfs subvolume create "${MOUNT}/@"
umount "${MOUNT}"
mount "${DRIVE}3" "${MOUNT}" --options subvol=@

mkdir --parents "${MOUNT}/boot/EFI"
mount "${DRIVE}1" "${MOUNT}/boot/EFI"
swapon "${DRIVE}2"

# ---==[ Install the OS and build the fstab file ]==---------------------------
timedatectl set-ntp true
pacstrap "${MOUNT}" base linux linux-firmware btrfs-progs
# basestrap "${MOUNT}" base
# manjaro https://forum.manjaro.org/t/howto-install-manjaro-using-cli-only/108203

cat << EOF > "${MOUNT}/etc/fstab"
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF
genfstab -p -t UUID "${MOUNT}" >> "${MOUNT}/etc/fstab"

# ---==[ Configure the new system ]==------------------------------------------
cp configure_x86_uefi.sh "${MOUNT}/root/"
arch-chroot "${MOUNT}" /root/configure_x86_uefi.sh
rm "${MOUNT}/root/configure_x86_uefi.sh"

# ---==[ Unmount everything ]==------------------------------------------------
# swapoff "${DRIVE}2"
# umount "${MOUNT}/boot/EFI"
# umount "${MOUNT}"
