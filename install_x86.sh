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
genfstab -p -t UUID "${MOUNT}" >> "${MOUNT}/etc/fstab"  # append

# ---==[ Configure the new system ]==------------------------------------------
if [ -z "${TIMEZONE}" ]; then
    TIMEZONE='UTC'
else
if [ -z "${LOCALE}" ]; then
    LOCALE='en_CA'
fi
if [ -z "${ENCODING}" ]; then
    ENCODING='UTF-8'
fi
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi
if [ -z "${HOSTNAME}" ]; then
    HOSTNAME='cuckoo'
fi
if [ -z "${DOMAIN}" ]; then
    DOMAIN='localdomain'
fi

cp configure_x86.sh "${MOUNT}/root/"
arch-chroot "${MOUNT}" \
    DOMAIN="${DOMAIN}" \
    DRIVE="${DRIVE}" \
    ENCODING="${ENCODING}" \
    HOSTNAME="${HOSTNAME}" \
    KEYMAP="${KEYMAP}" \
    LOCALE="${LOCALE}" \
    TIMEZONE="${TIMEZONE}" \
    /root/configure_x86.sh

# -----------------------------------------------------------------------------
# reboot
