Arch Linux Install
==================


Remote Control
--------------

First, boot the system from the ISO then configure a password for the root user
and start the ssh server::

    passwd
    systemctl start sshd

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

* https://mags.zone/help/arch-usb.html


UEFI Stuff
----------

::

    efibootmgr  # list the entries
    efibootmgr --delete-bootnum --bootnum 0000  # delete the Boot0000 entry


Caching Proxy Server For Packages
---------------------------------

* https://github.com/anatol/pacoloco


3-2-1 Rule
----------

2 is 1 and 1 is none...

* https://www.msp360.com/resources/blog/3-2-1-1-0-backup-rule
* https://community.veeam.com/blogs-and-podcasts-57/3-2-1-1-0-golden-backup-rule-569


Btrfs Bulk Storage
------------------

Prepare all the data drives and mount them::

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

    # Create a bunch of subvolumes
    mount /dev/mapper/${FIRST_DRIVE} /somewhere
    btrfs subvolume create /somewhere/@foo
    btrfs subvolume create /somewhere/@bar
    ...

    # Mount all the new subvolumes and the main drive for snapshotting
    mount -o subvolid=5 /dev/mapper/${FIRST_DRIVE} /somewhere
    mount -o subvol=@foo /dev/mapper/${FIRST_DRIVE} /elsewhere/foo
    mount -o subvol=@bar /dev/mapper/${FIRST_DRIVE} /elsewhere/bar
    ...

* https://markmcb.com/2020/01/07/five-years-of-btrfs
* https://ownyourbits.com/2018/03/09/easy-sync-of-btrfs-snapshots-with-btrfs-sync
* https://ramsdenj.com/2016/04/05/using-btrfs-for-easy-backup-and-rollback.html
* http://snapper.io
* https://btrfs.wiki.kernel.org/index.php/Incremental_Backup#Available_Backup_Tools
* https://github.com/AmesCornish/buttersink
* https://www.unixsheikh.com/articles/how-i-store-my-files-and-why-you-should-not-rely-on-fancy-tools-for-backup.html
* https://github.com/eamonnsullivan/backup-scripts
* https://arstechnica.com/gadgets/2021/09/examining-btrfs-linuxs-perpetually-half-finished-filesystem
* https://unixsheikh.com/articles/battle-testing-zfs-btrfs-and-mdadm-dm.html

::

    dd if=/dev/zero of=/dev/disk-by-id/ata-bla-bla-bla
    kill -USR1 $(pgrep ^dd$)


SMART Checking
--------------

::

    for drive in $(ls /dev/disk/by-id/{nvme,ata}* 2>&1 | grep -v 'No such' | grep -v eui | grep -v part); do
        echo -n "${drive} "
        smartctl -H ${drive} | grep result | sed 's/SMART overall-health self-assessment test result//'
    done

::

    smartctl -l selftest --json /dev/blablabla    # JSON output
    smartctl -l selftest --json=y /dev/blablabla  # YAML output

* https://github.com/AnalogJ/scrutiny#scrutiny  Go web UI???


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

    # Install some essential packages for file servers
    pacman --noconfirm --sync git man-db tree rsync samba

    # Make sure to create the new /etc/samba/smb.conf file first
    systemctl start smb
    systemctl enable smb

    # Set samba password for a user and list samba users
    useradd --create-home --groups marsupials bubba
    smbpasswd -a bubba
    pdbedit --list

* https://wiki.archlinux.org/title/Xdg-utils#xdg-open  mounting by clients
* https://serverfault.com/questions/913504/samba-smb-encryption-how-safe-is-it
* https://unix.stackexchange.com/questions/761491/securing-samba-smb-conf-best-parameters


Update Groups Without Logging Out
---------------------------------

::

    exec newgrp $(id --group --name)


Rsync Over SSH With Sudo
------------------------

::

    # Make certain tools available to a user without a password
    echo 'bubba ALL=NOPASSWD: /usr/bin/rsync' >> /etc/sudoers.d/bubba

    nohup rsync -avc --delete -e ssh --rsync-path='sudo rsync' \
        /elsewhere/foo/ wickedserver:/elsewhere/foo/ &

    disown

* https://crashingdaily.wordpress.com/2007/06/29/rsync-and-sudo-over-ssh
* https://www.techrepublic.com/article/how-to-run-a-command-that-requires-sudo-via-ssh
* https://blog.zazu.berlin/software/a-almost-perfect-rsync-over-ssh-backup-script.html
* http://duplicity.nongnu.org/features.html
* http://www.mikerubel.org/computers/rsync_snapshots
* https://samdoran.com/rsync-time-machine


Container Stuff
---------------

::

    # Ensure the sub?id stuff is there for each user
    echo "${USER}:100000:65536" | sudo tee -a /etc/subgid
    echo "${USER}:100000:65536" | sudo tee -a /etc/subuid
    echo "${OTHER_USER}:165536:65536" | sudo tee -a /etc/subgid
    echo "${OTHER_USER}:165536:65536" | sudo tee -a /etc/subuid
    # ...

::

    # Install essential packages for container hosts
    pacman --noconfirm --sync nerdctl                  # do "container stuff"
    pacman --noconfirm --sync buildkit cni-plugins     # ensure "build" works
    pacman --noconfirm --sync rootlesskit slirp4netns  # ensure "run" works

    # Prepare to actually "build" and "run" containers
    containerd-rootless-setuptool.sh install
    containerd-rootless-setuptool.sh install-buildkit

::

    echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.d/userns.conf

* https://github.com/jpetazzo/registrish#hosting-your-images-with-registrish
* https://vadosware.io/post/rootless-containers-in-2020-on-arch-linux
* https://pet2cattle.com/2022/02/nerdctl-rootless-buildkit
* https://github.com/containerd/nerdctl/blob/main/docs/config.md#properties
* https://blog.mobyproject.org/containerd-namespaces-for-docker-kubernetes-and-beyond-d6c43f565084
* https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1030928  nerdctl horribly broken in Debian


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
    # btrfs balance status /somewhere

    # Start a trim operation
    # TBD

    # Start a defragment operation
    # TBD

Show which files are corrupted (those uncorrectable errors found during a scrub operation)::

    dmesg | grep "checksum error"

* https://btrfs.wiki.kernel.org/index.php/Manpage/btrfs-balance
* https://btrfs.wiki.kernel.org/index.php/FAQ
* http://marc.merlins.org/linux/scripts/btrfs-scrub
* http://marc.merlins.org/perso/btrfs/post_2014-05-04_Fixing-Btrfs-Filesystem-Full-Problems.html
* https://wiki.tnonline.net/w/Btrfs/Replacing_a_disk
* https://ask.fedoraproject.org/t/btrfs-drive-logging-csum-failed-errors-time-to-replace/14116/2  csum won't go away?
* https://superuser.com/questions/858237/finding-files-with-btrfs-uncorrectable-errors
* https://github.com/tinyzimmer/btrsync  Golang stuff???
* https://serverfault.com/questions/1111998/btrfs-check-shows-checksum-verify-failed-even-after-scrub
* https://discussion.fedoraproject.org/t/btrfs-scrub-find-one-error-then-aborted-cannot-resumed/77445/6
* https://www.funtoo.org/BTRFS_Fun


Calculations
------------

::

    pacman -S python-btrfs
    btrfs-space-calculator -m raid1 -d raid1 16TB 10TB 6TB | grep --after-context=3 'Device sizes'
    btrfs-space-calculator -m raid1 -d raid1 16TB 10TB 6TB | grep 'Total unallocatable'

::

    Device sizes:
      Device 1: 14.55TiB
      Device 2: 9.09TiB
      Device 3: 5.46TiB

    Total unallocatable raw amount: 0.00B

* https://www.carfax.org.uk/btrfs-usage


ZFS Stuff
---------

Mounting::

    zpool import -d /dev/disk/by-id tank1

Scrubbing::

    zpool scrub tank1

Snapshots::

    zfSnap -s -S -v \
        -a 6m tank1/set1 \
        -a 6m tank1/set2  # keep for 6 months
    # -s = Don't do anything on pools running resilver
    # -S = Don't do anything on pools running scrub
    # -v = Verbose output
    # -a ttl = Set how long snapshot should be kept

    zfSnap -d  # delete expired snapshots
    # -d = Delete old snapshots

AUR::

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

* https://archzfs.leibelt.de  script to yank ZFS onto running live CD
* https://github.com/stevleibelt/arch-linux-live-cd-iso-with-zfs  ready-made live CD
* https://github.com/eoli3n/archiso-zf  another script to yank ZFS onto running live CD
* https://eoli3n.github.io/2020/04/25/recovery.htm  another script to yank ZFS onto running live CD
* https://eoli3n.github.io/2020/05/01/zfs-install.html  another script to yank ZFS onto running live CD


VM Host
-------

::

    # Get virtualization stuff going
    pacman --noconfirm --sync qemu-headless

    # Get libvirt working
    pacman --noconfirm --sync libvirt
    service systemctl start libvirtd
    usermod -aG libvirt ${USER}

    # Get network stuff working
    pacman --noconfirm --sync dnsmasq iptables-nft
    # pacman --noconfirm --sync bridge-utils
    # pacman --noconfirm --sync openbsd-netcat
    # pacman --noconfirm --sync vde2


Ugly Stuff
----------

::

    # Ensure the CPU microcode gunk is doing it's mysterious thing
    pacman --noconfirm --sync amd-ucode  # or intel-ucode

    # Ensure NTP is running
    pacman --noconfirm --sync ntp
    systemctl enable ntpd
    systemctl start ntpd

Dump Bluetooth MAC address::

    sudo cat /sys/kernel/debug/bluetooth/hci0/identity | cut -d' ' -f1


Orphaned Packages
-----------------

To remove packages that were brought in by installing other packages that are no longer needed::

    pacman -Rns $(pacman -Qtdq)


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
* https://turlucode.com/arch-linux-install-guide-step-1-basic-installation
* https://github.com/kimono-koans/httm
* https://github.com/ChrisTitusTech/ArchTitus
* https://maximiliangolia.com/blog/2022-10-wol-plex-server


TODO
----

* Provide a working enrypted filesystem/swap option
* Repair the non-UEFI amd64 installer script so grub works properly


Encryption Magic
----------------

* http://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
* https://www.freedesktop.org/software/systemd/man/systemd-cryptenroll.html
* https://github.com/gandalfb/openmediavault-full-disk-encryption#create-derived-keys-and-crypttab
* https://unix.stackexchange.com/questions/392284/using-a-single-passphrase-to-unlock-multiple-encrypted-disks-at-boot/392286#392286
* https://gist.github.com/vms20591/b8b17b3c44fc9b62ff734c0b588014db
* https://wiki.archlinux.org/title/Dm-crypt/Specialties#Encrypted_system_using_a_detached_LUKS_header

::

    dd if=/dev/zero of=header.img bs=16M count=1
    cryptsetup luksFormat --header header.img --offset 32768 /dev/sda1
    cryptsetup open --header header.img /dev/sda1 moo


Desktop Linux Annoyances
------------------------

Mouse cursor::

    # Ensure package 'adwaita-cursors' is installed, then...
    gsettings set org.cinnamon.desktop.interface cursor-theme Adwaita

Network Manager::

    gsettings set org.gnome.nm-applet disable-connected-notifications true
    gsettings set org.gnome.nm-applet disable-disconnected-notifications true
    gsettings set org.gnome.nm-applet disable-vpn-notifications true

Firefox::

    # about:config
    privacy.resistFingerprinting = true

* https://mudkip.me/2024/03/28/Notes-on-EndeavourOS  fancy stuff?
* https://github.com/vmavromatis/gnome-layout-manager  Unity, macOS, Winderz look-alikes using GNOME???
* https://www.theregister.com/2023/02/27/lomiri_desktop_on_debian  Lomiri == Unity == meh
* https://forum.endeavouros.com/t/manual-partitioning-with-luks-and-btrfs/51483
* https://github.com/vinceliuice/WhiteSur-gtk-theme  macOS theme

Adjust the automatic partition layouts::

    # Boot the liveCD
    # Edit /etc/calamares/modules/partition.conf
    # Replace "100%" with some other value, change the size of the EFI partition, etc.
    # Then run the installer


FAT Rsync
---------

When working with FAT filesystems and trying to rsync stuff over (e.g:  USB drives)::

    rsync -rtcvP --delete foo/ bar/


Debian Live Installer
---------------------

* https://forums.debian.net/viewtopic.php?t=155802  Calamares setup for btrfs subvolumes
* https://chaos.tomaskral.eu/guides/debian-encrypted-btrfs-root
* https://www.paritybit.ca/blog/debian-with-btrfs
