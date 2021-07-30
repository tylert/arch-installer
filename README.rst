Arch Linux Install
==================


Remote Control
--------------

First, boot the system from the ISO then configure a password for the root user
and start the ssh server::

    passwd
    systemctl start sshd.service

* https://wiki.archlinux.org/index.php/Install_Arch_Linux_via_SSH


Installing
----------

To start the install process (including some sample environment variables)::

    curl -Ol https://raw.githubusercontent.com/tylert/arch-installer/master/install_x86_uefi.sh
    curl -Ol https://raw.githubusercontent.com/tylert/arch-installer/master/configure_x86_uefi.sh
    chmod +x install_x86_uefi.sh
    chmod +x configure_x86_uefi.sh
    NEWHOSTNAME=numuh NEWUSERNAME=sheen NEWPASSWORD=awesome ./install_x86_uefi.sh


btrfs Bulk Storage
------------------

Prepare all the data drives and mount them::

    # Update the entire system to the latest versions
    pacman --sync --refresh --upgrade

    # Install required packages
    pacman --sync --noconfirm btrfs-progs cryptsetup rsync smartmontools

    # Encrypt the drive and bring it online (the "ata-*" ones)
    for DRIVE in ${FIRST_DRIVE} ${SECOND_DRIVE}; do
        cryptsetup luksFormat /dev/disk/by-id/${DRIVE}
        cryptsetup luksOpen /dev/disk/by-id/${DRIVE} ${DRIVE}
    done

    # Format the drives
    mkfs.btrfs \
        -m raid1 \
        -d raid1 \
        -L megaarray \
        /dev/mapper/${FIRST_DRIVE} \
        /dev/mapper/${SECOND_DRIVE} ...
    mount /dev/mapper/${FIRST_DRIVE} /somewhere

    # Create a bunch of subvolumes
    btrfs subvolume create /somewhere/@foo
    btrfs subvolume create /somewhere/@bar
    ...

    # Enable compression automatically
    btrfs property set /somewhere compression zstd
    btrfs property set /somewhere/@foo compression zstd
    btrfs property set /somewhere/@bar compression zstd
    ...

    # Mount all the new subvolumes and the main drive for snapshotting
    # The compress-force=zstd options is not needed if the property has been set
    mount -o compress=zstd,subvolid=5 /dev/mapper/${FIRST_DRIVE} /somewhere
    mount -o compress=zstd,subvol=@foo /dev/mapper/${FIRST_DRIVE} /elsewhere/foo
    mount -o compress=zstd,subvol=@bar /dev/mapper/${FIRST_DRIVE} /elsewhere/bar
    ...

* https://markmcb.com/2020/01/07/five-years-of-btrfs/
* https://ownyourbits.com/2018/03/09/easy-sync-of-btrfs-snapshots-with-btrfs-sync/
* https://ramsdenj.com/2016/04/05/using-btrfs-for-easy-backup-and-rollback.html
* http://snapper.io/
* https://btrfs.wiki.kernel.org/index.php/Incremental_Backup#Available_Backup_Tools
* https://github.com/AmesCornish/buttersink
* https://crashingdaily.wordpress.com/2007/06/29/rsync-and-sudo-over-ssh/
* https://www.unixsheikh.com/articles/how-i-store-my-files-and-why-you-should-not-rely-on-fancy-tools-for-backup.html


Samba Mount Setup
-----------------

::

    # Update the entire system to the latest versions
    pacman --sync --refresh --upgrade

    # Install new essential packages
    pacman --sync --noconfirm git man-db tree samba

    # Prepare samba
    # Copy config file over first into /etc/samba/smb.conf
    systemctl start smb.service
    systemctl enable smb.service

    # Set samba password for a user and list samba users
    useradd --create-home --groups users bubba
    smbpasswd -a bubba
    pdbedit --list


Rsync Over SSH With Sudo
------------------------

::

    # Make certain tools available to a user without a password
    bubba ALL=NOPASSWD: /usr/bin/rsync

    nohup rsync -avc --delete -e ssh --rsync-path='sudo rsync' /elsewhere/foo/ wickedserver:/elsewhere/foo/ &
    disown


Btrfs Maintenance
-----------------

You might want to have a look at the btrfsmaintenance package at https://github.com/kdave/btrfsmaintenance.

::

    # Start a scrubbing operation
    btrfs scrub start /somewhere
    btrfs scrub status /somewhere

    # Start a rebalancing operation
    btrfs balance start --background --full-balance /somewhere
    btrfs balance status /somewhere

    # Start a trim operation
    # TBD

    # Start a defragment operation
    # TBD


AUR ZFS
-------

::

    # Update the entire system to the latest versions
    pacman --sync --refresh --upgrade

    # Prepare the build environment
    pacman --sync --noconfirm base-devel git linux-headers

    # Install ZFS packages
    gpg --keyserver keys.gnupg.net --recv-keys 6AD860EED4598027
    git clone https://aur.archlinux.org/zfs-utils.git
    git clone https://aur.archlinux.org/zfs-dkms.git
    pushd zfs-utils
    makepkg -si
    popd
    pushd zfs-dkms
    makepkg -si
    popd


References
----------

* https://github.com/elasticdog/packer-arch/blob/master/arch-template.json
* http://blog.redit.name/posts/2014/arch-linux-install-btrfs-root-with-snapshots.html
* http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html
* https://github.com/egara/arch-btrfs-installation
* https://www.vultr.com/docs/install-arch-linux-with-btrfs-snapshotting
* https://wiki.archlinux.org/index.php/Installation_guide
* https://github.com/bianjp/archlinux-installer
* https://blog.chendry.org/2015/02/06/automating-arch-linux-installation.html
* https://github.com/helmuthdu/aui
* https://turlucode.com/arch-linux-install-guide-step-1-basic-installation/


TODO
----

* repair the non-UEFI x86_64 installer script so grub works properly
