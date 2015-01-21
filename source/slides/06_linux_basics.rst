.. _06_linux_basics:

Syslog, Cron, mdadm and other tools
===================================

Class reminders
---------------

* HW #1 due on Friday at start of class
* Midterm week from Friday

Automated OS Install followup
-----------------------------

* How did you do?
* Do we need to walk through it today again?
* HW #2 will cover this

Syslog
======

Syslog architecture
-------------------

* Syslog daemon (rsyslog is popular)
* ``/dev/log`` UNIX domain socket

  * Applications write to socket
  * Syslog listens to socket

* Log rotation

  * ``logrotate`` application
  * Properly sends ``HUP`` commands to release file handles

Typical log files
-----------------

*This can vary depending on the syslog config file*

.. csv-table::
  :header: File, Contents

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

* Run commands a specific times or intervals
* "crontab" or "cron table" -- configuration file
* Various methods for configuring

  * User crontabs -- stored in ``/var/spool/cron``, managed via ``crontab -e``
  * Predefined hourly, daily, and monthly directories
  * ``/etc/cron.d`` folder

* Configuration gets automatically reloaded every minute
* ``man 5 crontab`` extremely useful!

Crontab format
--------------

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

**Never edit the user files directly in ``/var/spool/cron``**

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
* ``$PATH`` can be different depending on the user
* Generally safer to use absolute paths

Software RAID (mdadm)
=====================
