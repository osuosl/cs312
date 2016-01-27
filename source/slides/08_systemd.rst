.. _08_systemd:

systemd
=======

Topics
------

* systemd basics
* systemd vs. sysv
* cgroups primer
* Resource management

systemd
-------

* Relatively new init system
* Started at RedHat
* Adopted by most Linux Distributions nowadays

What problems does systemd try to solve?
----------------------------------------

* Proper service dependencies
* Starting/stopping services on-demand
* Preserving the output of daemons
* Utilize Linux cgroups to increase security and improve performance
* Tracks and manages mount points
* Manage hostname, timezone and other settings
* Faster boot process
* Backwards compatible with SysV
* Replaces several services

What does systemd replace?
--------------------------

.. csv-table::

  init, syslog
  udev, acpid
  crond/atd, ConsoleKit
  pm-utils, inetd
  automount, watchdog

systemd Unit Types
------------------

Systemd introduces the concept of *systemd units*

.. csv-table::
  :header: Unit Type, File Extension, Description
  :widths: 10, 10, 15

  Service unit, ``.service``, A system service.
  Target unit, ``.target``, A group of systemd units.
  Automount unit, ``.automount``, A file system automount point.
  Device unit, ``.device``, A device file recognized by the kernel.
  Mount unit, ``.mount``, A file system mount point.
  Path unit, ``.path``, A file or directory in a file system.

systemd Unit Types
------------------

.. csv-table::
  :header: Unit Type, File Extension, Description
  :widths: 10, 10, 15

  Scope unit, ``.scope``, An externally created process.
  Slice unit, ``.slice``, "A group of hierarchically organized units that manage
  system processes."
  Snapshot unit, ``.snapshot``, A saved state of the systemd manager.
  Socket unit, ``.socket``, An inter-process communication socket.
  Swap unit, ``.swap``, A swap device or a swap file.
  Timer unit, ``.timer``, A systemd timer.

Systemd Unit Locations
----------------------

Normally we look in ``/etc/init.d/`` for start up scripts, but not for systemd.

  ``/usr/lib/systemd/system/``
    Systemd units distributed with installed RPM packages.
  ``/run/systemd/system/``
    Systemd units created at run time. This directory takes precedence over the
    directory with installed service units.
  ``/etc/systemd/system/``
    Systemd units created and managed by the system administrator. This
    directory takes precedence over the directory with runtime units.

Managing Services: Start/Stop
-----------------------------

.. code-block:: bash

  # Init
  service httpd {start,stop,restart,reload}

  # systemd
  systemctl {start,stop,restart,reload} httpd.service

  # Glob units when needed
  systemctl restart httpd mysql

  # If unit isn't specified, .service is assumed
  systemctl start httpd # == systemctl start httpd.service

  # Shell completion is highly recommended
  yum install bash-completion
  source /etc/profile
  systemctl start <tab>

Managing Services: Status
-------------------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Init
  $ service httpd status
  httpd.worker (pid  9114) is running...

  # systemd
  $ systemctl status httpd
  httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
     Active: active (running) since Wed 2016-01-27 19:20:02 UTC; 2min 24s ago
       Docs: man:httpd(8)
             man:apachectl(8)
   Main PID: 2019 (httpd)
     Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
     CGroup: /system.slice/httpd.service
             ├─2019 /usr/sbin/httpd -DFOREGROUND
             ├─2020 /usr/sbin/httpd -DFOREGROUND
             ├─2021 /usr/sbin/httpd -DFOREGROUND
             ├─2022 /usr/sbin/httpd -DFOREGROUND
             ├─2023 /usr/sbin/httpd -DFOREGROUND
             └─2024 /usr/sbin/httpd -DFOREGROUND

  Jan 27 19:20:01 systemd systemd[1]: Starting The Apache HTTP Server...
  Jan 27 19:20:02 systemd systemd[1]: Started The Apache HTTP Server.

Managing Services: Status
-------------------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  # list loaded services
  $ systemctl -t service
  UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
  httpd.service                loaded active running The Apache HTTP Server

  # list installed services (similar to chkconfig --list)
  $systemctl list-unit-files -t service
  UNIT FILE                                   STATE
  httpd.service                               disabled
  <snip>
  147 unit files listed.

  # view state
  systemctl --state failed

Managing Services: Enable/Disable
---------------------------------

.. code-block:: bash

  # init
  chkconfig httpd {on,off}

  # systemd
  systemctl {enable,disable,mask,unmask} httpd.service

Targets == Runlevels
--------------------

* Runlevels are exposed as target units
* Target names are more useful:

  * ``multi-user.target`` vs. ``runlevel3``
  * ``graphical.target`` vs. ``runlevel5``

.. code-block:: bash

  # View the default target
  $ systemctl get-default
  multi-user.target

  # Set the default target
  systemctl set-default [target]

  # Change at run-time
  systemctl isolate [target]

* ``/etc/inittab`` is no longer used!

Systemd Units
-------------

::

  [Unit]
  Description=The Apache HTTP Server
  After=network.target remote-fs.target nss-lookup.target
  Documentation=man:httpd(8)
  Documentation=man:apachectl(8)

  [Service]
  Type=notify
  EnvironmentFile=/etc/sysconfig/httpd
  ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
  ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
  ExecStop=/bin/kill -WINCH ${MAINPID}
  KillSignal=SIGCONT
  PrivateTmp=true

  [Install]
  WantedBy=multi-user.target

Systemd Units: File structure
-----------------------------

``[Unit]``
  Contains generic options that are not dependent on the type of the unit. These
  options provide unit description, specify the unit's behavior, and set
  dependencies to other units.

``[Unit Type]``
  If a unit has type-specific directives, these are grouped under a section
  named after the unit type. For example, service unit files contain the
  ``[Service]`` section.

``[Install]``
  Contains information about unit installation used by systemctl enable and
  disable commands.

``[Unit]`` Section Options
--------------------------

.. csv-table::
  :header: Option, Description
  :widths: 5, 10

  ``Description``, A meaningful description of the unit.
  ``Documentation``, "Provides a list of URIs referencing documentation for the
  unit."
  ``After``, "Defines the order in which units are started. The ``Before``
  option has the opposite functionality to ``After``."
  ``Requires``, Configures dependencies on other units.
  ``Wants``, Configures weaker dependencies than ``Requires``.
  ``Conflicts``, "Configures negative dependencies, an opposite to
  ``Requires``."

``[Unit]`` Section Example: Postfix
-----------------------------------

::

  [Unit]
  Description=Postfix Mail Transport Agent
  After=syslog.target network.target
  Conflicts=sendmail.service exim.service

``[Service]`` Section Options
-----------------------------

.. csv-table::
  :widths: 5, 10
  :header: Option, Description

  ``Type``, "Configures the unit process startup type that affects the
  functionality of ``ExecStart`` and related options."
  ``ExecStart``, "Specifies commands or scripts to be executed when the unit is
  started."
  ``ExecStop``, "Specifies commands or scripts to be executed when the unit is
  stopped."
  ``ExecReload``, "Specifies commands or scripts to be executed when the unit is
  reloaded."
  ``Restart``, "Service is restarted after the process exits, except when its
  been cleanly stopped."

Service Types
-------------

``simple``
  The default value. The process started with ``ExecStart`` is the main process
  of the service.
``forking``
  The process started with ``ExecStart`` spawns a child process that becomes the
  main process of the service. The parent process exits when the startup is
  complete.
``oneshot``
  This type is similar to simple, but the process exits before starting
  consequent units.
``notify``
  This type is similar to simple, but consequent units are started only after a
  notification message.

``[Service]`` Section Example: Postfix
--------------------------------------

::

  [Service]
  Type=forking
  PIDFile=/var/spool/postfix/pid/master.pid
  EnvironmentFile=-/etc/sysconfig/network
  ExecStartPre=-/usr/libexec/postfix/aliasesdb
  ExecStartPre=-/usr/libexec/postfix/chroot-update
  ExecStart=/usr/sbin/postfix start
  ExecReload=/usr/sbin/postfix reload
  ExecStop=/usr/sbin/postfix stop

How does it work?
~~~~~~~~~~~~~~~~~

* Composed of and controls units with varying types rather than daemons

  - service, socket, device, mount, automount, swap, target, path, timer, slice,
    scope

* Generic ``[Unit]`` and ``[Install]`` configurations, in addition to
  type-specific configuration
* Units may not be empty, but have no other generic requirements
* Default behavior is to start the target named ``default``

Dependencies
~~~~~~~~~~~~

* Defining deps

  * ``Requires`` means a unit file must exist for the required unit (+ ``Wants`` behavior)
  * ``Wants`` means a unit file should be started with this unit, if it exists (Does not imply ordering)

* Defining ordering

  * ``Before``, ``After`` define ordering.

Resources
---------

* http://www.freedesktop.org/wiki/Software/systemd/
* https://en.wikipedia.org/wiki/Systemd
* https://fedoraproject.org/wiki/Systemd
* https://rhsummit.files.wordpress.com/2014/04/summit_demystifying_systemd1.pdf
