Arch Linux Install
==================


Starting
--------

First, boot the system from the ISO (via USB).  Second, enable ssh and give root a password::

    systemctl enable sshd.service
    systemctl start sshd.service
    passwd


Partitioning
------------

::

    BLOCK_DEVICE='/dev/sda'

    # Dump the partition table
    sfdisk --dump ${BLOCK_DEVICE} > sda.dump

    # Restore the partition table
    sfdisk ${BLOCK_DEVICE} < sda.dump


Btrfs
-----

::

    BLOCK_DEVICE='/dev/sda3'
    MOUNT_POINT='/mnt'

    # Mount the main btrfs volume
    mkfs.btrfs --force --label os ${BLOCK_DEVICE}
    mkdir --parents ${MOUNT_POINT}
    mount ${BLOCK_DEVICE} ${MOUNT_POINT} --options defaults,ssd,discard

    # Create the btrfs subvolume magic
    btrfs subvolume list ${MOUNT_POINT}
    btrfs subvolume create ${MOUNT_POINT}/@
    btrfs subvolume create ${MOUNT_POINT}/@snapshot
    btrfs subvolume list ${MOUNT_POINT}
    btrfs subvolume get-default ${MOUNT_POINT}
    btrfs subvolume set-default 256 ${MOUNT_POINT}
    umount ${MOUNT_POINT}

    # Mount the subvolumes
    mount ${BLOCK_DEVICE} ${MOUNT_POINT} --options defaults,ssd,discard,subvol=@
    mkdir --parents ${MOUNT_POINT}/.snapshot
    mount ${BLOCK_DEVICE} ${MOUNT_POINT}/.snapshot --options defaults,ssd,discard,subvol=@snapshot


References
----------

* http://blog.redit.name/posts/2014/arch-linux-install-btrfs-root-with-snapshots.html
* http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html
* https://github.com/egara/arch-btrfs-installation
* https://www.vultr.com/docs/install-arch-linux-with-btrfs-snapshotting
* https://wiki.archlinux.org/index.php/Installation_guide
* https://github.com/bianjp/archlinux-installer
* https://blog.chendry.org/2015/02/06/automating-arch-linux-installation.html
* https://github.com/helmuthdu/aui
* https://turlucode.com/arch-linux-install-guide-step-1-basic-installation/
