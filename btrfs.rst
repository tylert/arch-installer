::

    # Mount the main btrfs volume
    mkfs.btrfs --force --label os /dev/sda1
    mkdir /mnt/target
    mount /dev/sda1 /mnt/target --options defaults,ssd,discard

    # Create the btrfs subvolume magic for snapshots and everything else
    btrfs subvolume list /mnt/target
    btrfs subvolume create /mnt/target/@
    btrfs subvolume create /mnt/target/@snapshot
    btrfs subvolume list /mnt/target
    btrfs subvolume get-default /mnt/target
    btrfs subvolume set-default 257 /mnt/target
    umount /mnt/target

    # Mount the subvolume
    mount /dev/sda1 /mnt/target --options defaults,ssd,discard,subvol=@


References
----------

* http://blog.redit.name/posts/2014/arch-linux-install-btrfs-root-with-snapshots.html
* http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html
* https://github.com/egara/arch-btrfs-installation
* https://www.vultr.com/docs/install-arch-linux-with-btrfs-snapshotting
