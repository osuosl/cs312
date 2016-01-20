.. _06_linux_basics:

Syslog, Cron & Software RAID
============================

Syslog
======

Syslog architecture
-------------------

* Syslog daemon

  * ``rsyslog`` - traditional, persistent logging
  * ``journald`` - systemd binary log
  * Both exist on CentOS 7 at the same time

* ``/dev/log`` UNIX domain socket

  * Applications write to socket
  * Syslog daemons listens to socket

* Log rotation

  * ``logrotate`` application
  * Properly sends ``HUP`` commands to release file handles


Typical log files
-----------------

*This can vary depending on the syslog config file*

.. csv-table::
  :header: File, Contents
  :widths: 10, 20

  auth.log/secure, "Auth, sudo, sshd, user adds"
  boot.log, Output from init scripts
  cron.log/cron, Cron runs and errors
  dmesg, Dump of kernel messages
  lastlog, Last login time per user (binary)
  mail.log/maillog, All mail logs
  messages, Main system logs (i.e. catch all typically)
  wtmp, Login records (binary)
  yum.log, package management log

Syslog facilities
-----------------

*Categories and levels defined in the kernel*

.. csv-table::
  :header: Facility, Description

  \*, Everything
  authpriv, Sensitive and private messages (i.e. /var/log/secure)
  cron, Cron daemon messages
  daemon, System daemons
  kern, Kernel messages
  local0-7, Various local messages

Syslog severity levels
----------------------

*In descending severity..*

.. csv-table::
  :header: Level, Description

  emerg, Panic situations
  alert, Urgent situations
  crit, Critical conditions
  err, Other error conditions
  warning, Warning messages
  notice, Things that might merit investigation
  info, Information messages
  debug, Debug messages

Remote logging
--------------

* Send syslog messages off-site
* Why Useful?

  * Security -- send messages offsite so they can't be tampered
  * Send to a central location (or multiple locations)
  * Can be sent to a logging aggregation service (i.e. elastic search)

* UDP vs. TCP

  * Older method used UDP/514
  * Newer support for TCP+SSL

Rsyslog
-------

* Default on most distributions
* *"The Rocket-fast SYStem for LOG processing"*
* Was created in 2004 by Rainer Gerhards to offer competition to syslog-ng
* Builtin-in SSL support for TCP remote logging
* More easily extensible with plugins (i.e. mysql, hdfs, etc)
* Easier to use with config management software
* syslog-ng

  * Started opensource, shifted towards commercial license
  * Developed by a company (Balabit)
  * `rsyslog vs. syslog-ng`_

.. _rsyslog vs. syslog-ng: http://www.rsyslog.com/doc/rsyslog_ng_comparison.html

Rsyslog config
--------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  # GENERAL CONFIG
  $ModLoad imuxsock # provides support for local system logging (e.g. via logger
                    # command)
  $ModLoad imklog   # provides kernel logging support (previously done by rklogd)
  # Use default timestamp format
  $ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
  # Include all config files in /etc/rsyslog.d/
  $IncludeConfig /etc/rsyslog.d/*.conf

  # RULES
  # Log anything (except mail) of level info or higher. Don't log private
  # authentication messages!
  *.info;mail.none;authpriv.none;cron.none                /var/log/messages
  # The authpriv file has restricted access.
  authpriv.*                                              /var/log/secure
  # Log all the mail messages in one place.
  mail.*                                                  -/var/log/maillog
  # Log cron stuff
  cron.*                                                  /var/log/cron
  # Everybody gets emergency messages
  *.emerg                                                 *
  # Save news errors of level crit and higher in a special file.
  uucp,news.crit                                          /var/log/spooler
  # Save boot messages also to boot.log
  local7.*                                                /var/log/boot.log

Rsyslog remote logging
----------------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Client config
  # Send all logs to remote loghost using TCP
  *.* @@loghost.example.org:10514

  # Server (loghost) config
  # Use TCP
  module(load="imtcp")
  input(type="imtcp" port="10514")
  # Define a template for where to put the logs
  $template DailyPerHostLogs,"/var/log/HOSTS/%HOSTNAME%/%YEAR%-%MONTH%-%DAY%.log"
  # Send all logs using the template
  *.* -?DailyPerHostLogs

Rsyslog also supports `TLS/SSL over TCP`_.

.. _TLS/SSL over TCP: http://www.rsyslog.com/doc/rsyslog_tls.html

Accessing logs with systemd
---------------------------

* Systemd provides its own logging daemon which can be accessed using
  ``journalctl``
* Systemd stores all of its logs in a binary format
* A few useful commands:

.. code-block:: bash

  # Tail the log and watch it live
  $ journalctl -f
  # Filter by priority
  $ journalctl -p err
  # Filter by time
  $ journalctl --since="2016-01-20 05:00:00"
  # Filter by unit (service)
  $ journalctl -u crond

`RedHat journalctl Documentation`_

.. _RedHat journalctl Documentation: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-Using_the_Journal.html

Userspace tools: logger
-----------------------

* ``logger`` is a userspace shell command interface to syslog
* Useful for adding to scripts were you want to put information in logs
* Tag entries with arbitrary words that you can filter with later

.. code-block:: bash

  $ logger -t mirror "trigger set centos"

  # output will be:
  # Jan 21 18:55:38 hostname.example.org mirror: trigger set centos

  # Send a message to the auth facility using the info severity level
  $ logger -p auth.info "Set user john locked"

Cron
====

Cron: Schedule commands
-----------------------

* Typically also known as *vixie-cron* (why?)
* Run commands a specific times or intervals
* "crontab" or "cron table" -- configuration file
* Various methods for configuring

  * User crontabs -- stored in ``/var/spool/cron``, managed via ``crontab -e``
  * Predefined hourly, daily, and monthly directories
  * ``/etc/cron.d`` folder

* Configuration gets automatically reloaded every minute
* ``man 5 crontab`` extremely useful!

Other cron-like services
------------------------

* **anacron**

  * Jobs that don't assume the system is running continuously
  * Control the daily, hourly, weekly or monthly jobs

* **fcron**

  * Alternative to vixie-cron, also has anacron features
  * More featureful, can set nice level or do things based on load average

* **systemd timers**

  * A lot more features
  * Doesn't use traditional crontabs

Crontab format
--------------

*Taken from 'man 5 crontab'*

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Example of job definition:
  # .---------------- minute (0 - 59)
  # |  .------------- hour (0 - 23)
  # |  |  .---------- day of month (1 - 31)
  # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
  # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
  # |  |  |  |  |
  # *  *  *  *  * user-name command to be executed

  # minute hour dom month weekday command

  # run five minutes after midnight, every day
  5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
  # run at 2:15pm on the first of every month -- output mailed to paul
  15 14 1 * *     $HOME/bin/monthly
  # run at 10 pm on weekdays, annoy Joe
  0 22 * * 1-5    mail -s "It’s 10pm" joe%Joe,%%Where are your kids?%
  23 0-23/2 * * * echo "run 23 minutes after midn, 2am, 4am ..., everyday"
  5 4 * * sun     echo "run at 5 after 4 every sunday"

Managing user crontabs
----------------------

**Never edit the user files directly in** ``/var/spool/cron``

.. code-block:: bash

  # Edit the current user crontab
  $ crontab -e

  # Edit user john's crontab
  $ crontab -e -u john

Other Crontab files
-------------------

.. csv-table::
  :header: File/Directory, Description

  /etc/crontab, Primary system crontab file
  /etc/cron.d/, Arbitrary crontab formatted files
  /etc/anacrontab, "system crontab that manages cron.daily, weekly, hourly and monthly"
  /etc/cron.daily/, Scripts that will run daily
  /etc/cron.hourly/, Scripts that will run hourly
  /etc/cron.monthly/, Scripts that will run monthly
  /etc/cron.weekly/, Scripts that will run weekly

Crontab environment variables
-----------------------------

Can set any arbitrary environment variables in crontab

.. csv-table::
  :header: Variable, Description

  MAILTO, Email address to send stdout/stderr output to
  SHELL, Default shell to use

* cron environments don't have the same env vars that regular users
  have!
* Likely not sourcing ``~/.{shell}rc`` files
* ``$PATH`` can be different depending on the user
* Generally safer to use absolute paths

Software RAID (mdadm)
=====================

mdadm
-----

* Utility to create, assemble, report on and monitor software RAID arrays
* Utilizes the md kernel driver
* Can use raw partitions, but we prefer making partitions
* Adds metadata to the disk

When should you use mdadm?
--------------------------

* Lower cost of hardware
* Standardize RAID using one method
* Others?

Formatting and Booting
----------------------

* Use ``fdisk`` to set the filesystem type to ``fd Linux raid auto``

  * Assists with auto-building on boot

* ``/boot`` needs to either be a RAID1 or a regular partition

  * Grub1/2 can't read RAID5 md devices
  * After grub boots, the initrd will take care of building the mdadm array for
    the rootfs

Creating a RAID1
----------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  $ yum install mdadm

  # Note: I created loop0/1 using dd and losetup
  $ fdisk /dev/loop0

  $ mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/loop0 /dev/loop1
  mdadm: Note: this array has metadata at the start and
      may not be suitable as a boot device.  If you plan to
      store '/boot' on this device please ensure that
      your boot-loader understands md/v1.x metadata, or use
      --metadata=0.90
  Continue creating array? y
  mdadm: Defaulting to version 1.2 metadata
  mdadm: array /dev/md0 started.

  $ cat /proc/mdstat
  Personalities : [raid1]
  md0 : active raid1 loop1[1] loop0[0]
        20416 blocks super 1.2 [2/2] [UU]

  unused devices: <none>

/etc/mdadm.conf
---------------

If the partition is set to ``fd``, the kernel should automatically detect it
and build the array based on the metadata on the partition.

.. code-block:: bash

  # Show metadata about arrays using md devices
  $ mdadm --detail --scan
  ARRAY /dev/md0 metadata=1.2 name=mdadm:0 UUID=ead812c6:ee734fb3:fcb6264d:e3a00c40

  # Add it to the config file (not required, but useful)
  $ mdadm --detail --scan >> /etc/mdadm.conf

  # Stop the array
  $ mdadm --stop /dev/md0
  mdadm: stopped /dev/md0

  # Start (assemble) the array
  $ mdadm --assemble /dev/md0
  mdadm: /dev/md0 has been started with 2 drives.

Monitoring mdadm
----------------

* ``mdmonitor`` service on CentOS; ``mdadm`` on Debian
* Runs ``mdadm --monitor`` and reads ``mdadm.conf``
* Needs either ``MAILADDR`` or ``PROGRAM`` set in ``mdadm.conf`` to run properly
* Program to run when it detects an event

Dealing with failures
---------------------

.. code-block:: bash

  # Simulate a disk failure
  $ mdadm /dev/md0 -f /dev/loop1
  mdadm: set /dev/loop1 faulty in /dev/md0

  $ journalctl -n 10 -k
  Jan 20 21:52:33 kernel: md0: detected capacity change from 0 to 4
  Jan 20 21:52:33 kernel:  md0: unknown partition table
  Jan 20 21:53:29 kernel: md/raid1:md0: Disk failure on loop1, disa
                          md/raid1:md0: Operation continuing on 1 d
  Jan 20 21:53:29 kernel: RAID1 conf printout:
  Jan 20 21:53:29 kernel:  --- wd:1 rd:2
  Jan 20 21:53:29 kernel:  disk 0, wo:0, o:1, dev:loop0
  Jan 20 21:53:29 kernel:  disk 1, wo:1, o:0, dev:loop1
  Jan 20 21:53:29 kernel: RAID1 conf printout:
  Jan 20 21:53:29 kernel:  --- wd:1 rd:2
  Jan 20 21:53:29 kernel:  disk 0, wo:0, o:1, dev:loop0

Dealing with failures
---------------------

.. code-block:: bash

  # Hot remove the disk
  $ mdadm /dev/md0 -r /dev/loop1
  mdadm: hot removed /dev/loop1 from /dev/md0

  # Check the status of the array
  $ cat /proc/mdstat
  Personalities : [raid1]
  md0 : active raid1 loop0[0]
        20416 blocks super 1.2 [2/1] [_U]

  unused devices: <none>

  # Hot add the drive back
  $ mdadm /dev/md0 -a /dev/loop1
  mdadm: added /dev/loop1

More information about an md device
-----------------------------------

.. rst-class:: codeblock-sm

::

  $ mdadm -D /dev/md0
  /dev/md0:
          Version : 1.2
    Creation Time : Wed Jan 20 16:56:25 2016
       Raid Level : raid1
       Array Size : 409024 (399.50 MiB 418.84 MB)
    Used Dev Size : 409024 (399.50 MiB 418.84 MB)
     Raid Devices : 2
    Total Devices : 2
      Persistence : Superblock is persistent
      Update Time : Wed Jan 20 22:01:02 2016
            State : clean
   Active Devices : 2
  Working Devices : 2
   Failed Devices : 0
    Spare Devices : 0
             Name : mdadm:0  (local to host mdadm)
             UUID : 87f67b6c:622ca752:4dd25200:6b3f23c5
           Events : 39

      Number   Major   Minor   RaidDevice State
         0       7        0        0      active sync   /dev/loop0
         2       7        1        1      active sync   /dev/loop1


Block device metadata
---------------------

.. rst-class:: codeblock-sm

::

  $ mdadm -E /dev/loop1
  /dev/loop1:
            Magic : a92b4efc
          Version : 1.2
      Feature Map : 0x0
       Array UUID : ead812c6:ee734fb3:fcb6264d:e3a00c40
             Name : mdadm:0  (local to host mdadm)
    Creation Time : Wed Jan 21 22:13:57 2015
       Raid Level : raid1
     Raid Devices : 2
   Avail Dev Size : 40896 (19.97 MiB 20.94 MB)
       Array Size : 20416 (19.94 MiB 20.91 MB)
    Used Dev Size : 40832 (19.94 MiB 20.91 MB)
      Data Offset : 64 sectors
     Super Offset : 8 sectors
     Unused Space : before=0 sectors, after=64 sectors
            State : clean
      Device UUID : bac67523:e1f44d96:a64c1322:50135cf9
      Update Time : Wed Jan 21 22:28:43 2015
    Bad Block Log : 512 entries available at offset 48 sectors
         Checksum : 92d13b09 - correct
           Events : 39
     Device Role : Active device 0
     Array State : AA ('A' == active, '.' == missing, 'R' == replacing)
