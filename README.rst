Arch Linux Install
==================


Starting
--------

First, boot the system from the ISO (via USB).  Second, enable ssh and give root a password::

    systemctl enable sshd.service
    systemctl start sshd.service
    passwd


Links
-----

* https://wiki.archlinux.org/index.php/Installation_guide
* https://github.com/bianjp/archlinux-installer
* https://blog.chendry.org/2015/02/06/automating-arch-linux-installation.html
* https://github.com/helmuthdu/aui
* https://turlucode.com/arch-linux-install-guide-step-1-basic-installation/
