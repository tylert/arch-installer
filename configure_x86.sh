#!/usr/bin/env bash

# Do the things that must be done inside the arch-chroot

set -xe

# ---==[ Set up the timezone and system clock ]==------------------------------
if [ -z "${TIMEZONE}" ]; then
    TIMEZONE='UTC'
fi

ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc --utc

# ---==[ Set up the system language, locale and keymap ]==---------------------
if [ -z "${LOCALE}" ]; then
    LOCALE='en_CA'
fi
if [ -z "${ENCODING}" ]; then
    ENCODING='UTF-8'
fi
if [ -z "${KEYMAP}" ]; then
    KEYMAP='us'
fi

sed -i "/^#${LOCALE}.${ENCODING} ${ENCODING} /s/^#//" /etc/locale.gen
locale-gen

cat << EOF > /etc/locale.conf
LANG=${LOCALE}.${ENCODING}
LANGUAGE=${LOCALE}
LC_ALL=C
EOF

echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# ---==[ Set up the new hostname and hosts file ]==----------------------------
if [ -z "${NEWHOSTNAME}" ]; then
    NEWHOSTNAME='cuckoo'
fi
if [ -z "${DOMAIN}" ]; then
    DOMAIN='localdomain'
fi

echo "${NEWHOSTNAME}" > /etc/hostname

cat << EOF > /etc/hosts
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1  localhost
127.0.1.1  ${NEWHOSTNAME} ${NEWHOSTNAME}.${DOMAIN}
::1  localhost ip6-localhost ip6-loopback
ff02::1  ip6-allnodes
ff02::2  ip6-allrouters
EOF

# ---==[ Set up networking ]==-------------------------------------------------
pacman --sync --noconfirm dhcpcd openssh wireguard-arch wireguard-tools
systemctl enable dhcpcd
systemctl enable sshd.service

# ---==[ Set up a base user and group ]==--------------------------------------
if [ -z "${NEWUSERNAME}" ]; then
    NEWUSERNAME='marvin'
fi
if [ -z "${PASSWORD}" ]; then
    PASSWORD=''
fi

useradd -m "${NEWUSERNAME}"

pacman --sync --noconfirm sudo
echo "${NEWUSERNAME} ALL=(ALL) ALL" > "/etc/sudoers.d/${NEWUSERNAME}"

# ---==[ Install other things we can't live without ]==------------------------
pacman --sync --noconfirm vim

# ---==[ Build initrd ]==------------------------------------------------------
pacman --sync --noconfirm btrfs-progs
# /etc/mkinitcpio.conf
# XXX Maybe do more stuff here XXX
# HOOKS="base udev ... block filesystems ..."
# HOOKS="base udev ... block lvm2 filesystems ..."
# HOOKS="... encrypt ... filesystems ..."
mkinitcpio -p linux

# ---==[ Set up boot loader stuff ]==------------------------------------------
# If UEFI is enabled
# XXX Maybe do more stuff here XXX
# ls /sys/firmware/efi/efivars
pacman --sync --noconfirm grub
grub-install --target=i386-pc "${DRIVE}"
grub-mkconfig -o /boot/grub/grub.cfg
