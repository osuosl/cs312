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

Software RAID (mdadm)
=====================
