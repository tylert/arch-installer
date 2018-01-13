::

    # Mount the main btrfs volume
    mkfs.btrfs -f -L os /dev/sda1
    mkdir /mnt/btrfs
    mount -o defaults,relatime,discard,ssd /dev/sda1 /mnt/btrfs

    # Create the btrfs magic for snapshots and the / subvol
    mkdir /mnt/btrfs/_snapshot
    mkdir /mnt/btrfs/_current
    btrfs subvol create /mnt/btrfs/_current/slash

    # Mount the / subvol
    mkdir /mnt/arch
    mount -o defaults,relatime,discard,ssd,nodev,subvol=_current/slash /dev/sda1 /mnt/arch


References
----------

* http://blog.redit.name/posts/2014/arch-linux-install-btrfs-root-with-snapshots.html
* http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html
* https://github.com/egara/arch-btrfs-installation
* https://www.vultr.com/docs/install-arch-linux-with-btrfs-snapshotting
