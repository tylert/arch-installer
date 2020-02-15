Arch Linux Install
==================


Remote Control
--------------

First, boot the system from the ISO then configure a password for the root user
and start the ssh server::

    passwd
    systemctl start sshd.service


Installing
----------

To start the install process (including some sample environment variables)::

    DRIVE=/dev/sdx ./setup_x86_uefi_server.sh
    HOSTNAME=numuh USERNAME=sheen ./install_x86.sh


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
