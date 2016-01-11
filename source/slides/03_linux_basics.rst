.. _03_linux_basics:

Linux Basics (Day 3)
====================

Filesystems, system booting and services

Filesystem
==========

The Linux Filesystem Hierarchy
------------------------------

What's a filesystem?

    *In computing, a file system is used to control how information is stored and
    retrieved. Without a file system, information placed in a storage area would
    be one large body of information with no way to tell where one piece of
    information stops and the next begins.*

    -- (http://en.wikipedia.org/wiki/Filesystem)

Which Filesystem to choose
--------------------------

.. csv-table::
  :widths: 5, 30

  ext4, "pretty standard now, rock solid, medium performance"
  ext3, "Still ok, but not good for large filesystems"
  ext2, "Legacy, only useful in special use cases (i.e. use drives, /boot)"
  xfs, "Great performance (multi-threaded, great for large filesystems)"
  brtfs, "ZFS-like filesystem for Linux. Has lots of potential but not quite
  ready for production"

The File System
---------------

.. figure:: ../_static/you_are_here.jpg
    :align: center
    :scale: 75%

.. code-block:: bash

  $ ls /
  bin  boot  data  dev  etc  home  lib  lib64  lost+found  media  
  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  util  var

Installed programs and utilities
--------------------------------

.. code-block:: bash

  /bin                /usr/sbin
  /sbin               /usr/local/bin
  /usr/bin            /usr/local/sbin

``PATH`` environment variable

.. code-block:: bash

  $ echo $PATH
  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

``which`` command

.. code-block:: bash

  $ which bash
  /bin/bash

Where are drives mounted?
----------------------------

* Raw device appears under ``/dev``.

::

  $ dmesg | tail
  [260930.20]  sdb: sdb1
  [260930.32] sd 6:0:0:0: >[sdb] Asking for cache data failed
  [260930.32] sd 6:0:0:0: >[sdb] Assuming drive cache: write through
  [260930.32] sd 6:0:0:0: >[sdb] Attached SCSI removable disk

* USB filesystem under ``/media``, main disk ``/``
* You can manually mount devices with ``mount``

  * *"Everything's a file"*
  * ``umount`` to unmount

* ``/etc/fstab`` tells things where to mount
* ``/etc/mtab`` shows where things are currently mounted

Three Tiers of Filesystem Hierarchy
-----------------------------------

.. image:: ../_static/hierarchy.jpg
    :align: right
    :scale: 70%

* ``/``, essential for system booting and mounting ``/usr``.
* ``/usr``, read-only system data for normal system operation.
* ``/usr/local``, locally-installed software.

  * Package managers usually install under ``/`` and ``/usr``.

See also ``man hier``

\/bin & \/sbin
--------------

* Store binaries that are used to boot system and mount other fileystems
* binaries for all users in ``/bin``, binaries used by root are in ``/sbin``
* Things like ``mount``, ``echo``, ``chmod``, ``hostname``

\/usr (Historical Context)
--------------------------

People were running out of disk space so:

* All binaries not required for base system + booting + mounting other
  devices went in ``/usr/bin`` and ``/usr/sbin``
* These binaries were typically manually compiled and installed by the user
* Eventually some unices (linux didn't exist yet) took over
  ``/usr/bin`` and ``/usr/sbin`` for the location that packages were
  installed to.
* Now manually installed (without package manager) binaries go in
  ``/usr/local/bin`` and ``/usr/local/sbin``.

\/usr (Modern Context)
----------------------

.. code-block:: bash

  $ ls /usr
  bin  games    lib    libexec  sbin   src
  etc  include  lib64  local    share  tmp

.. csv-table::
  :header: Location, Description
  :widths: 10, 30

  /usr/bin,Packages installed by package manager
  /usr/sbin,Packages installed by package manager
  /usr/etc,Rarely used; files from /etc can be symlinked here
  /usr/games,Binaries for games and educational programs

\/usr (Modern Context)
----------------------

.. csv-table::
  :header: Location, Description
  :widths: 10, 30

  /usr/include,Include files for the C compiler
  /usr/lib,Object libraries (including dynamic libs); some unusual binaries
  /usr/lib64,64-bit libraries
  /usr/libexec,Executables used with libraries; not used much
  /usr/local,Programs (and their configuration) locally installed by user go here
  /usr/share,Application data; typically examples and documentation
  /usr/src/linux,Kernel source goes here

\/dev
-----

* Device files, which often refer to physical devices

  * ``/dev/sd?``
  * ``/dev/sr?``
  * ``/dev/tty*``

* Special character devices:

  * ``/dev/null`` -- sink for writes
  * ``/dev/random`` -- high quality randomness (blocking)
  * ``/dev/urandom`` -- non-blocking random
  * ``/dev/zero`` -- always reads 0s

\/etc
-----

* Configuration files local to the machine
* Programs almost always look here for configuration first

\/home
------

* Contains homedirs of regular users
* Sometimes symlinked to ``/usr/home``, but rarely on linux

\/lib & \/lib64
---------------

* Libraries needed to boot and run commands related to bootstrapping

\/media & \/mnt
---------------

* Used as mount points for other devices (usb sticks, nfs, etc)
* Most Desktop Environments automatically mount things to ``/media``

\/proc
------

Special filesystem ``procfs`` contains a file-representation of the current
state of the kernel and running processes.

.. code-block:: bash

  # Which Linux kernel version are you running?
  $ cat /proc/version
  Linux version 2.6.32-504.3.3.el6.x86_64 (mockbuild@c6b8.bsys.dev.centos.org)
  (gcc version 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC) ) #1 SMP Wed Dec 17
  01:55:02 UTC 2014

.. code-block:: bash

  # Learn about system's hardware
  $ less /proc/cpuinfo
  $ less /proc/meminfo

.. code-block:: bash

  # Some parts of /proc can be written as well as read...
  $ echo 3 > /proc/sys/vm/drop_caches # drop caches

\/sys
-----

* File-representation of device drivers, subsystems, and hardware
  loaded into the kernel
* Similar to ``sysctl`` on other Unixy systems

\/var
-----

* Multi-purpose: log, temporary, transient, and spool files
* Typically contains run-time data
* Cache

User-Specific Data & Configuration
----------------------------------

* Data stored at ``/home/<username>``

  * Desktop environment creates folders Documents, Pictures, Videos, etc.
* Configurations in dotfiles within home (``/.``)

* ``lost+found`` is **not** your desktop trash can

  * Lost blocks of the filesystem.
  * Usually not an issue.
  * If your desktop provides backups of deleted files, they'll be somewhere
    in ``/home/<username>/``

Space on drives
---------------

Use ``df`` to see disk free space.

.. code-block:: bash

  $ df -h /
  Filesystem      Size  Used Avail Use% Mounted on
  /dev/sda8        73G   29G   41G  42% /

Use ``du`` to see disk usage.

.. code-block:: bash

    $ du -sh /home/
    21G /home/

Default output is in bytes, ``-h`` for human-readable output.

Commands for working with filesystems
-------------------------------------

Creating filesystems

.. code-block:: bash

  $ mkfs -t ext4 /dev/sdb1
  $ mkfs.ext4 /dev/sdb1
  # Each FS has their own options. Look at man mkfs.<filesystem>

Mounting filesystems

.. code-block:: bash

  $ mount /dev/sdb1 /data
  # -t for type
  # -o for options
  # requires device path and mount point
  $ umount /data

More filesystem commands
------------------------

Tuning filesystems

.. code-block:: bash

  $ tune2fs -m 0 /dev/sda1
  # -m Reserved Blocks Percentage
  # -l List contents of the superblock

Resizing filesystems online

.. code-block:: bash

  $ resize2fs /dev/sda1
  $ xfs_growfs /data

* ext* requires a clean filesystem
* ext can be shrunk, while xfs cannot
* XFS uses the mountpoint for growing online

devfs
-----

.. code-block:: bash

  /dev/sd*
  /dev/sr*
  /dev/null
  /dev/random
  /dev/urandom
  /dev/zero

Blocks and dd
-------------

* Block size is the size of chunks allocated for files

* dd

  * Disk duplicator (or disk dump).

    * ``if=<path>`` -- input file.
    * ``of=<path>`` -- ooutput file.
    * ``bs=<size>`` -- block size.
    * ``count=<size>`` -- number of block to transfer.

.. code-block:: bash

  $ dd if=/dev/random of=/dev/sda
  # What will this do?

Filesystem Consistency
----------------------

* Metadata vs. data

  * Metadata is extra information the filesystem tracks about the file
  * Data is the file's contents

* Filesystem is **consistent** if all metadata is intact

  * ``fsck`` or ``fsck.<filesystem>`` is FileSystem Consistency Check
  * Always check filesystem manual page for filesystem specific checks

.. code-block:: bash

  $ fsck.ext4 -C 0 /dev/sda1
  # -C 0 displays progress output to stdout
  # Always do this in an "offline" state, i.e. single user mode

More about Journaling
---------------------

- Filesystem consistency tool; protections against system freezes, power
  outages, etc.
- Replaying the journal.
- ext4’s three modes of journaling:

  - :journal: Data and metadata to journal.
  - :ordered: Data updates to filesystem, then metadata committed to journal.
  - :writeback: Metadata comitted to journal, possibly before data updates.

- ext4 journaling differs from ext3 because it uses a single-phase
  checksum transaction, allowing it to be done asynchronously.

Booting
=======

.. figure:: ../_static/xkcd-fight.png
    :align: center
    :scale: 100%

Steps in boot process
---------------------

.. image:: ../_static/booting.png
    :align: right
    :scale: 70%

#. Kernel initialization
#. Hardware configuration
#. System processes
#. Operator intervention (single-user)
#. Execution of start-up scripts
#. Multi-user operation

POST
----

* Power On Self Test
* BIOS
* Initializes hardware at very low level

  * ensures it is accessible
  * does **not** load drivers

BIOS/UEFI
---------

* PCs vs Proprietary hardware

  * BIOS, UEFI, OpenBoot PROM, etc
* BIOS

  * **B**\ asic **I**\ nput/**O**\ utput **S**\ ystem
  * Very simple compared to OpenBoot PROM / UEFI
  * Select devices to boot from
  * MBR (first 512 bytes)

* UEFI

  * **U**\ nified **E**\ xtensible **F**\ irmware **I**\ nterface
  * Successor to BIOS
  * Flexible pre-OS environment including network booting

Bootloader
----------

* Responsible for booting the kernel
* Contained in first 512 bytes (MBR scheme)
* Can chainload to another bootloader

Bootloader
----------

* Most linux-based systems use GRUB

  * GRand Unified Bootloader

* LILO (LInux LOader) is an uncommon alternative
* syslinux, isolinux are often used for usb/cd images

Boot Loaders (Grub)
-------------------

* **Gr**\ and **U**\ nified **B**\ ootloader
* Dynamic fixes during booting
* Can read the filesystem
* Index based – ``(hd0,0) = sda1``
* Grub "version 1" vs. "version 2"

  * Version 2 has more features, but more complicated
  * Latest Debian, Ubuntu and Fedora use v2

.. code::

  grub> root (hd0,0)    (Specify where your /boot partition resides)
  grub> setup (hd0)     (Install GRUB in the MBR)
  grub> quit            (Exit the GRUB shell)

  grub-install

GRUB Configuration
------------------

* CentOS 6 (your VMs) use GRUB 0.97
* Main configuration is in ``/boot/grub/menu.lst``
* kernels and initrds live in ``/boot``

::

  default=0
  timeout=0
  splashimage=(hd0,0)/boot/grub/splash.xpm.gz
  hiddenmenu
  title CentOS 6 (2.6.32-504.3.3.el6.x86_64)
    root (hd0,0)
    kernel /boot/vmlinuz-2.6.32-504.3.3.el6.x86_64 ro \
      root=UUID=bf569295-826b-4abd-8519-bd5ff29708c9 rd_NO_LUKS \
      rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 \
      crashkernel=auto KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM \
      console=ttyS0,115200n8 console=tty0 quiet
    initrd /boot/initramfs-2.6.32-504.3.3.el6.x86_64.img

GRUB Configuration
------------------

* ``root`` -- boot partition
* ``kernel`` -- your linux kernel!
* ``initrd`` -- initial ram disk which is mounted to help you boot

Bootstrapping
-------------

* *Pull itself up by its own bootstraps*
* Automatic and manual booting
* Driver Loading
* Period of vulnerability

  * configuration errors
  * missing hardware
  * damaged filesystems

* ``init`` -- **Always Process ID (PID) #1**

  * First process to start
  * Either a binary or can be a simple script (even a bash shell!)

initrd
------

* Initial Ram Disk
* Ram disk contains enough to mount ``/``
* runs ``/init`` on the ramdisk (before mounting the **real** ``/``)
  , which mounts ``/`` and runs the new init:

.. code-block:: bash

   for f in /mount/*.sh; do
     [ -f "$f" ] && . "$f"
     [ -d "$NEWROOT/proc" ] && break;
   done
   ...
   exec switch_root "$NEWROOT" "$INIT" $initargs

* mostly necessary if you are using ``lvm``, ``cryptsetup (LUKS)``, or other
  complex configurations

real init
---------

* PID 1 (because it is the first thing that runs!)
* Ancestor to every other process
* Runs all other startup scripts (networking, etc)
* Most linuces are settling on ``systemd`` as their init system

  * alternatives: systemv, openrc, bsd-style, upstart
  * your Centos 6 VM uses upstart, Centos 7 uses systemd

Single User Mode
----------------

.. image:: ../_static/single-user-mode.png
    :align: right
    :scale: 60%

* What is it used for?

  * Troubleshoot problems
  * Manual Filesystem Checks
  * Booting with bare services
  * Fix boot problems
  * Add “single” to kernel option

* Solaris/BSD

  * ``boot -s``

Startup Script Tasks
--------------------

.. figure:: ../_static/fsck.jpg
    :align: center
    :scale: 75%

* Setting up hostname & timezone
* Checking disks with fsck
* Mounting system's disks
* Configuring network interfaces
* Starting up daemons & network services

System-V Boot Style
-------------------

* Linux derived from System-V originally
* Alternative init systems

  * **systemd** - Fedora 15+, Redhat 7+ and Debian* (dependency driven)
  * **upstart** - Ubuntu, Redhat 6 (event driven, faster boot times)

Run levels:

================= =============================
level 0           sys is completely down (halt)
level 1 or S      single-user mode
level 2 through 5 multi-user levels
level 6           reboot level
================= =============================

/etc/inittab
------------

* Tells init what to do on each level
* Starts ``getty`` (terminals, serial console)
* Commands to be run or kept running
* ``inittab`` not used with systemd or upstart

.. code::

  # The default runlevel.
  id:2:initdefault:

  # What to do in single-user mode.
  ~~:S:wait:/sbin/sulogin

  # What to do when CTRL-ALT-DEL is pressed.
  ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

  # terminals
  1:2345:respawn:/sbin/getty 38400 tty1
  T0:23:respawn:/sbin/getty -L ttyS0 9600 vt100

init.d Scripts
--------------

* One script for one service/daemon
* Start up services such as sshd, httpd, etc
* Commands

  * start, stop, reload, restart
* sshd init script

.. code-block:: bash

  $ service sshd status
  openssh-daemon (pid  1186) is running...

  $ service sshd restart
  Stopping sshd:                                             [  OK  ]
  Starting sshd:                                             [  OK  ]

Starting services on boot
-------------------------

* rc\ **level**\ .d (rc0.d, rc1.d)
* S = start, K = stop/kill
* Numbers to set sequence (S55sshd)
* chkconfig / update-rc.d

  * Easy way to enable/disable services in RH/Debian
* Other distributions work differently

.. code-block:: bash

  $ chkconfig --list sshd
  sshd            0:off 1:off 2:on  3:on  4:on  5:on  6:off

  $ chkconfig sshd off

  $ chkconfig --list sshd
  sshd            0:off 1:off 2:off 3:off 4:off 5:off 6:off

Configuring init.d Scripts
--------------------------

* /etc/sysconfig (RH) or /etc/defaults (Debian)
* source Bash scripts
* Daemon arguments
* Networking settings
* Other distributions are vastly different

.. code-block:: bash

  $ cat /etc/sysconfig/ntpd
  # Drop root to id 'ntp:ntp' by default.
  OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid -g"

Shutting Down
-------------

* Not Windows, don't reboot to fix issue
* Can take a long time (i.e. servers)
* Reboot only to

  * load new kernel
  * new hardware
  * system-wide configuration changes
* ``shutdown``, ``reboot``, ``halt``, ``init``
* ``wall`` - send system-wide message to all users

.. code-block:: bash

  $ wall hello world
  Broadcast message from root@localhost (pts/0) (Fri Jan 31 00:40:29 2014):

  hello world

Readings
--------

* Jan 14th, Ch. 6, 8.9, 12.1
* Jan 16th Ch. 8.1-8.8
* Friday -- **Bring your laptop!**

  * Install Virtualbox (we'll go over this on Wed)
