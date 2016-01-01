.. _01_linux_basics:

Distribution History
====================

Today's topics
--------------

* Linux Distribution History
* Linux basics: users, basic commands and permissions
* Files
* Package management

Announcements
-------------

* Please bring your laptop on Friday

What is a Linux Distribution?
-----------------------------

  *"A Linux distribution (often called a distro for short) is an operating
  system made as a collection of software based around the Linux kernel and
  often around a package management system."* [Wikipedia-distro]

* Assortment of application and utility software packaged in a way that it meets
  users' needs
* Typically composed of: Linux Kernel, package manager, GNU tools & libraries,
  window system & manager and a desktop environment
* Types range from personal desktop, server, supercomputers, embedded to
  container distributions

.. [Wikipedia-distro] http://en.wikipedia.org/wiki/Linux_distribution

Linux beyond the kernel
-----------------------

- Linus had a kernel, but no userland
- Early distributions were created and shared by universities
- Linux GPL conversion finished by v0.99 which opened up commercial use

Early Distributions
-------------------

.. image:: ../_static/slackware-logo.jpg
  :align: right
  :width: 40%

.. image:: ../_static/debian-logo.png
  :align: right

.. image:: ../_static/redhat-logo.png
  :align: right
  :width: 40%

.. image:: ../_static/opensuse-logo.png
  :align: right
  :width: 30%

* Slackware
* Debian
* Red Hat
* SuSE
* `Linux Distribution Timeline`_

.. _Linux Distribution Timeline: http://futurist.se/gldt/

Slackware
---------

.. image:: ../_static/slackware-logo.jpg
  :align: right
  :width: 40%

* Patrick Volkerding modified SLS and created the first "fork" distribution
  Slackware
* First version released on June 7, 1993
* SuSE was forked from Slackware
* Prides itself being the most *"Unix-like Linux Distribution"*
* Oldest maintained distribution

Debian
------

  *"This is just to announce the imminent completion of a brand-new Linux
  release, which I'm calling the Debian Linux Release. This is a release that I
  have put together basically from scratch; in other words, I didn't simply make
  some changes to SLS and call it a new release. I was inspired to put together
  this release after running SLS and generally being dissatisfied with much of
  it, and after much altering of SLS I decided that it would be easier to start
  from scratch."* [Debian-Ian-Murdock] - August 17, 1993

.. [Debian-Ian-Murdock] http://groups.google.com/group/comp.os.linux.development/msg/a32d4e2ef3bcdcc6

Red Hat
-------

.. image:: ../_static/redhat-logo.png
  :align: right
  :width: 40%

* Marc Ewing started Red Hat Linux in 1994
* Was working on writing applications for UNIX but couldn't afford a UNIX
  workstation ($10k!)
* Discovered Linux, spent more time fixing Linux than working on the original
  project
* Decided to *".. work on putting together a better Linux Distribution"*
* Became first billion dollar open source public company
* Fedora/CentOS are community driven distributions based on Red Hat

SuSe
----

.. image:: ../_static/opensuse-logo.png
  :align: right
  :width: 30%

* Created by Roland Dyroff, Thomas Fehr, Burchard Steinbild and Hubert Mantel
* SuSe stands for Software und System-Entwicklung in German (Software and
  Systems Development)
* Started as a UNIX consulting company but did not pan out
* Originally a German translation of Slackware
* Became frustrated with Slackware's closed development, decided to create its
  own distribution and switched to using RPM
* Created YaST, an easy-to-use installation & configuration tool

Different approaches
--------------------

* Philosophy

  * `Debian Manifesto`_ - vision for a free and open distribution
    developed and maintained communally

* Software and Package management: apt/deb, yum/rpm
* Upstream software changes and configuration
* Installation scripts
* Freedom to create a system how they like it

.. _Debian Manifesto: https://www.debian.org/doc/manuals/project-history/ap-manifesto.en.html

Filling the niches
------------------

Each distribution fills a specific niche

:Gentoo: source based meta distribution used to create ChromeOS
:Android: Mobile platform using the Linux kernel but its own unique userland
:OpenWRT: Embedded wifi router distribution
:LTSP: Thin client distribution used in some K12 schools
:Tails: Security and privacy focused disto that is livecd/usb based
:CoreOS: Specialize in massive container deployments

You name it, there's a `distro out there`_!

.. _distro out there: http://lwn.net/Distributions/

What we'll be using
-------------------

**CentOS 7**

Why?

* Provides a nice balance between distro philosophies
* Very common in the enterprise
* Somewhat easier to understand and use
* We have more experience with it

Linux Basics
============

What are users?
---------------

* You, right now

.. code-block:: bash

    $ whoami    # your username
    $ who       # who is logged in?
    $ w         # who is here and what are they doing?
    $ id        # user ID, group ID, and groups you're in

* Not just people: Apache, Mailman, ntp aka "system users"

Users have
----------

* Username
* UID
* Group
* Shell
* Usually (but not always) password
* Usually (but not always) home directory

Managing users
--------------

.. code-block:: bash

    $ cat /etc/passwd
    # username:x:UID:GID:GECOS:homedir:shell
    $ useradd $USER # vs adduser, the friendly Ubuntu version
    $ userdel $USER
    $ passwd

.. figure:: ../_static/xkcd215.png
    :align: center
    :width: 85%

.. code-block:: bash

    # GECOS: full name, office number and building, office phone extension,
    # home phone number (General Electric Comprehensive Operating System)
    $ chfn # change GECOS information
    $ finger # tells you someone's GECOS info

Passwords
---------

* ``/etc/shadow``, not ``/etc/passwd``

.. code-block:: bash

    user@localhost ~ $ ls -l /etc/ | grep shadow
    -rw-r-----  1 root shadow   1503 Nov 12 17:37 shadow

    $ sudo su -
    $ cat /etc/shadow
    daemon:*:15630:0:99999:7:::
    bin:*:15630:0:99999:7:::
    sys:*:15630:0:99999:7:::
    mail:*:15630:0:99999:7:::

    # name:hash:time last changed: min days between changes: max days
    #    between changes:days to wait before expiry or disabling:day of
    #    account expiry

    $ chage # change when a user's password expires

Root/Superuser
--------------

* UID 0
* ``sudo``

.. figure:: ../_static/xkcd149.png
    :align: center

Sudo
----

Consult ``man 5 sudoers`` for more information:

.. rst-class:: codeblock-sm

::

  # User alias specification
  User_Alias  CS312_ADMIN = lance, jordane
  User_Alias  CS312_STUDENT = john, jane

  # Runas alias specification
  Runas_Alias ADMIN = root, sysadmin
  Runas_Alias STUDENT = httpd

  # Host alias specification
  Host_Alias OSU_NET = 128.193.0.0/16
  Host_Alias SERVERS = www, db

  # Cmnd alias specification
  Cmnd_Alias KILL = /bin/kill
  Cmnd_Alias SU = /bin/su

  #  User privilege specification
  root          ALL = (ALL) ALL
  CS312_ADMIN   ALL = NOPASSWD: ALL
  CS312_STUDENT OSU_NET = (STUDENT) KILL, SU

Acting as another user
----------------------

.. code-block:: bash

    $ su joe            # become user joe, with THEIR password
    $ su                # become root, with root's password
    $ sudo su -         # become root, with your password
    $ sudo su joe       # become user joe with your password

.. figure:: ../_static/xkcd838.png
  :align: center
  :scale: 75%

A dash after ``su`` provides an environment similar to what the user would
expect. Typically a good practice to always use ``su -``

What are groups?
----------------

Manage permissions for groups of users

.. code-block:: bash

    $ groupadd
    $ usermod
    $ groupmod
    $ gpasswd
    $ cat /etc/group
        root:x:0:
        daemon:x:1:
        bin:x:2:
        sys:x:3:
        adm:x:4:
        tty:x:5:
    # group name:password or placeholder:GID:member,member,member

Users won't be active in new group until they "log back in"

What are files?
---------------

* Nearly everything in metadata

Files have:

============= ==========================

Owner         atime, ctime, mtime
Group         POSIX ACLs
Permissions   Spinlock
Inode         i_ino
Size          read, write and link count
Filename

============= ==========================

.. code-block:: bash

    user@localhost ~ $ ls -il
    total 8
    2884381 drwxrwxr-x 5 user user 4096 Nov  6 11:46 Documents
    2629156 -rw-rw-r-- 1 user user    0 Nov 13 14:09 file.txt
    2884382 drwxrwxr-x 2 user user 4096 Nov  6 13:22 Pictures

More file metadata
------------------

.. rst-class:: codeblock-sm

::

  $ ll
  crw-rw-rw- 1 root  tty   5, 0 Jan  6 13:45 /dev/tty
  brw-rw---- 1 root  disk  8, 0 Dec 21 14:12 /dev/sda
  srw-rw-rw- 1 root  root  0    Dec 21 14:13 /var/run/acpid.socket
  prw------- 1 lance lance 0    Jan  5 17:44 /var/run/screen/S-lance/12138.ramereth
  lrwxrwxrwx 1 root  root  4    Nov 25 09:26 /var/run -> /run

  $ stat /etc/services
    File: `/etc/services'
    Size: 19303       Blocks: 40         IO Block: 4096   regular file
  Device: fc00h/64512d  Inode: 525111      Links: 1
  Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
  Access: 2015-01-07 08:22:43.768316048 -0800
  Modify: 2012-05-03 09:01:30.934310452 -0700
  Change: 2012-05-03 09:01:30.982310456 -0700
   Birth: -

File extensions
---------------

* ``.jpg``, ``.txt``, ``.doc``
* Really more of a recommendation
* File contains information about its encoding

.. code-block:: bash

    # Tells you about the filetype using magic file data, not file extension
    $ file $FILENAME

    user@localhost ~ $ file file.txt
    file.txt: ASCII text

    user@localhost ~ $ file squirrel.jpg
    squirrel.jpg: JPEG image data, JFIF standard 1.01

ls -l
------

* First bit: type
* Next 3: user
* Next 3: group
* Next 3: world

* user & group

.. code-block:: bash

    $ ls -l
    drwxrwxr-x 5 user user 4096 Nov  6 11:46 Documents
    -rw-rw-r-- 1 user user    0 Nov 13 14:09 file.txt
    drwxrwxr-x 2 user user 4096 Nov  6 13:22 Pictures

chmod and octal permissions
---------------------------

.. code-block:: bash

    +-----+--------+-------+
    | rwx | Binary | Octal |
    +-----+--------+-------+
    | --- | 000    | 0     |
    | --x | 001    | 1     |
    | -w- | 010    | 2     |
    | -wx | 011    | 3     |
    | r-- | 100    | 4     |
    | r-x | 101    | 5     |
    | rw- | 110    | 6     |
    | rwx | 111    | 7     |
    +-----+--------+-------+

* u, g, o for user, group, other
* -, +, = for remove, add, set
* r, w, x for read, write, execute

chown, chgrp
------------

user & group

.. code-block:: bash

    # Change the owner of myfile to "root".
    $ chown root myfile

    # Likewise, but also change its group to "staff".
    $ chown root:staff myfile

    # Change the owner of /mydir and subfiles to "root".
    $ chown -hR root /mydir

    # Make the group devops own the foo dir
    $ chgrp -R devops /home/user/foo

Types of files
--------------

.. code-block:: bash

    drwxrwxr-x      5 user    user      4096    Nov  6 11:46 Documents
    -rw-rw-r--      1 user    user         0    Nov 13 14:09 file.txt
    drwxrwxr-x      2 user    user      4096    Nov  6 13:22 Pictures
    ----------     -------  -------  -------- ------------ -------------
        |             |        |         |         |             |
        |             |        |         |         |         File Name
        |             |        |         |         +---  Modification Time
        |             |        |         +-------------   Size (in bytes)
        |             |        +-----------------------        Group
        |             +--------------------------------        Owner
        +----------------------------------------------   File Permissions

``-`` is a normal file

``d`` is a directory

``b`` is a block device

ACLs
----

* Access control lists
* Provides more fine grained control
* Requires filesystem support and mounted with acl flag
* Support depends on OS and filesystem
* Can make file management complicated if not done carefully

Package Management
------------------

*Take care of installation and removal of software*

**Core Functionality:**

* Install, Upgrade & uninstall packages easily
* Resolve package dependencies
* Install packages from a central repository
* Search for information on installed packages and files
* Pre-built binaries (usually)
* Find out which package provides a required library or file

Popular Linux Package Managers
------------------------------

**.deb**

* apt - Debian package manager with repo support
* dpkg - low level package manager tool used by apt
* Used by Debian, Ubuntu, Linux Mint and others

**.rpm**

* yum - RPM Package manager with repo support
* rpm - low level package manager tool used by yum
* Used by RedHat, CentOS, Fedora and others

Yum vs. Apt
-----------

**Yum**

* XML repository format
* Automatic metadata syncing
* Supports a plugin module system to make it extensible
* Checks all dependencies before downloading

**Apt**

* Upgrade and Dist-Upgrade

  * Dist-Upgrade applies intelligent upgrading decisions during a major system
    upgrade

* Can completely remove all files including config files
* Provides more features in the package format

RPM & yum (RedHat, CentOS, Fedora)
----------------------------------

.. image:: ../_static/rpm.png
    :align: right
    :width: 30%

**RPM**

  Binary file format which includes metadata about the package and the
  application binaries as well.

.. image:: ../_static/yum.png
    :align: right
    :width: 30%

**Yum**

  RPM package manager used to query a central repository and resolve RPM
  package dependencies.

Yum Commands (Redhat, CentOS, Fedora)
-------------------------------------

.. code-block:: bash

  # Searching for a package
  $ yum search tree

  # Information about a package
  $ yum info tree

  # Installing a package
  $ yum install tree

  # Upgrade all packages to a newer version
  $ yum upgrade

  # Uninstalling a package
  $ yum remove tree

  # Cleaning the RPM database
  $ yum clean all

RPM Commands
------------

Low level package management. No dependency checking or central repository.

.. code-block:: bash

  # Install an RPM file
  $ rpm -i tree-1.5.3-2.el6.x86_64.rpm

  # Upgrade an RPM file
  $ rpm -Uvh tree-1.5.3-3.el6.x86_64.rpm

  # Uninstall an RPM package
  $ rpm -e tree

  # Querying the RPM database
  $ rpm -qa tree

  # Listing all files in an RPM package
  $ rpm -ql tree

Apt (Debian, Ubuntu)
--------------------

* Similar commands to rpm/yum
* See comparisons `here`_

.. _here: https://help.ubuntu.com/community/SwitchingToUbuntu/FromLinux/RedHatEnterpriseLinuxAndFedora

Friday's Topics
---------------

* Editors
* Git
* Setting up your class environment (Openstack)

**Readings:**

* Chapter 3-4 & 7 by Jan 12th

Resources
---------

* http://www.linuxjournal.com/article/10724
* http://www.linuxadvocates.com/2013/03/yum-vs-apt-which-is-best.html
* http://futurist.se/gldt/
