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

    curl -Ol https://raw.githubusercontent.com/tylert/arch-installer/master/install_amd64_uefi.sh
    curl -Ol https://raw.githubusercontent.com/tylert/arch-installer/master/configure_amd64_uefi.sh
    chmod +x install_amd64_uefi.sh
    chmod +x configure_amd64_uefi.sh
    DRIVE=/dev/nvme0n1 SUFFIX=p NEWHOSTNAME=numuh NEWUSERNAME=sheen NEWPASSWORD=awesome ./install_amd64_uefi.sh
    DRIVE=/dev/sda SUFFIX='' NEWHOSTNAME=numuh NEWUSERNAME=sheen NEWPASSWORD=awesome ./install_amd64_uefi.sh


Btrfs Bulk Storage
------------------

Prepare all the data drives and mount them::

    # Update the entire system to the latest versions
    pacman --noconfirm --refresh --sync --upgrade

    # Install required packages
    pacman --noconfirm --sync btrfs-progs cryptsetup smartmontools

    # Encrypt the drive and bring it online (the "ata-*" ones)
    drives='
    FIRST_DRIVE
    SECOND_DRIVE
    '
    for drive in ${drives}; do
        cryptsetup luksFormat /dev/disk/by-id/${drive}
        cryptsetup luksOpen /dev/disk/by-id/${drive} ${drive}
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
* https://www.unixsheikh.com/articles/how-i-store-my-files-and-why-you-should-not-rely-on-fancy-tools-for-backup.html
* https://arstechnica.com/gadgets/2021/09/examining-btrfs-linuxs-perpetually-half-finished-filesystem/


SMART Checking
--------------

::

    for drive in $(ls /dev/disk/by-id/{nvme,ata}* 2>&1 | grep -v 'No such' | grep -v eui | grep -v part); do
        echo -n "${drive} "
        smartctl -H ${drive} | grep result | sed 's/SMART overall-health self-assessment test result//'
    done


Samba Mount Setup
-----------------

Build up a new /etc/samba/smb.conf.stub file containing your desired shares::

    [foo]
        path = /elsewhere/foo
        writable = yes
        browsable = yes
        guest ok = no
        create mask = 0664
        directory mask = 0775
        force group = marsupials

    [foo_ro]
        path = /elsewhere/foo
        writable = no
        browsable = yes
        guest ok = yes
        create mask = 0664
        directory mask = 0775
        force group = marsupials

    [bar]
        path = /elsewhere/bar
        writable = yes
        browsable = yes
        guest ok = no
        create mask = 0664
        directory mask = 0775
        force group = marsupials

    [bar_ro]
        path = /elsewhere/bar
        writable = no
        browsable = yes
        guest ok = yes
        create mask = 0664
        directory mask = 0775
        force group = marsupials

    # ...

::

    # Update the entire system to the latest versions
    pacman --noconfirm --refresh --sync --upgrade

    # Install some essential packages for file servers
    pacman --noconfirm --sync git man-db tree rsync samba

    # Prepare samba
    # Make sure to create the new /etc/samba/smb.conf file first
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
    echo 'bubba ALL=NOPASSWD: /usr/bin/rsync' >> /etc/sudoers.d/bubba

    nohup rsync -avc --delete -e ssh --rsync-path='sudo rsync' /elsewhere/foo/ wickedserver:/elsewhere/foo/ &
    disown

* https://crashingdaily.wordpress.com/2007/06/29/rsync-and-sudo-over-ssh/
* https://www.techrepublic.com/article/how-to-run-a-command-that-requires-sudo-via-ssh/


Btrfs Maintenance
-----------------

You might want to have a look at the btrfsmaintenance package at https://github.com/kdave/btrfsmaintenance.

::

    # Create new snapshots for today
    btrfs subvolume snapshot -r /somewhere/@foo /somewhere/@foo-$(date +%Y-%m-%d)
    btrfs subvolume snapshot -r /somewhere/@bar /somewhere/@bar-$(date +%Y-%m-%d)
    # ...

    # Delete all old snapshots from January through June
    btrfs subvolume delete /somewhere/@foo-2021-{01,02,03,04,05,06}-??
    btrfs subvolume delete /somewhere/@bar-2021-{01,02,03,04,05,06}-??
    # ...

::

    # Start a scrubbing operation
    btrfs scrub start /somewhere
    btrfs scrub status /somewhere

    # Start a rebalancing operation
    for ((i=0; i<100; i+=10)); do
        btrfs balance start -musage=${i} -dusage=${i} -v /somewhere
    done
    # for ((i=0; i<100; i+=10)); do
    #     btrfs balance start -mlimit=${i} -dlimit=${i} -v /somewhere
    # done
    # btrfs balance start --background --full-balance /somewhere
    btrfs balance status /somewhere

    # Start a trim operation
    # TBD

    # Start a defragment operation
    # TBD

* https://btrfs.wiki.kernel.org/index.php/Manpage/btrfs-balance
* https://btrfs.wiki.kernel.org/index.php/FAQ
* http://marc.merlins.org/linux/scripts/btrfs-scrub
* http://marc.merlins.org/perso/btrfs/post_2014-05-04_Fixing-Btrfs-Filesystem-Full-Problems.html


AUR ZFS
-------

::

    # Update the entire system to the latest versions
    pacman --noconfirm --refresh --sync --upgrade

    # Prepare the build environment
    pacman --noconfirm --sync base-devel git linux-headers

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


Cinnamon Desktop
----------------

::

    # Install the desktop environment and prerequisites
    pacman --noconfirm --sync xorg
    pacman --noconfirm --sync cinnamon gnome-terminal

    # Install a graphical login screen
    pacman --noconfirm --sync lightdm lightdm-gtk-greeter  # gdm
    systemctl enable lightdm  # gdm.service

    # Install other stuff???
    systemctl enable NetworkManager  # NetworkManager.service


VM Host
-------

::

    pacman --noconfirm --sync qemu-headless libvirt
    pacman --noconfirm --sync dnsmasq iptables-nft
    pacman --noconfirm --sync bridge-utils
    pacman --noconfirm --sync openbsd-netcat
    # pacman --noconfirm --sync vde2


Ugly Stuff
----------

::

    pacman --noconfirm --sync amd-ucode  # or intel-ucode


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

* Provide a working enrypted filesystem/swap option
* Repair the non-UEFI amd64 installer script so grub works properly
