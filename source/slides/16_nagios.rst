.. _16_nagios:

Monitoring: Nagios
==================

Monitoring Basics
-----------------


What types of resources should we monitor?

.. rst-class:: build

* Load
* Disk usage
* Memory/Swap usage
* Services: ssh, httpd, etc
* What else?

What is Nagios?
---------------

* Open source monitoring system
* Monitors Services

  * HTTP, SSH, ICMP, processor, load, etc

* Sends notifications of outages
* Offers a web interface

History of Nagios
-----------------

* Created in 1999 by Ethan Galstad
* Originally called "NetSaint" but was challenged for the trademark

  * Stands for *"Nagios Ain't Gonna Insist On Sainthood"*

* Icinga is a fork of Nagios created in 2009

  * Development process problems, lack of new features

* Nagios Plugins site

  * Community run site now called `Monitoring Plugins`_
  * Community collection of Nagios Plugins

.. _Monitoring Plugins: https://www.monitoring-plugins.org/

Components of Nagios
--------------------

.. rst-class:: build

**Core server process**
  * Core logic for monitoring
  * Keeps track of service states
  * Starts service checks
**CGI Web interface**
  * Simple web interface which connects to the core server process via sockets

Components of Nagios
--------------------

.. rst-class:: build

**Plugins**
  * Scripts written to gather monitoring information
  * Typically written in Perl, but can be written in about anything
  * Has an API that you follow to create your own plugin
**NRPE/NSCA**
  * Daemons that handle remote checks
  * NRPE: Active checking daemon
  * NSCA: Passive checking daemon (just listens for data)
    The client must:

    * Run the check (and schedule it)
    * Send the data to NSCA using ``send_nsca``

Passive vs. Active
------------------

.. image:: ../_static/nrpe.png
  :align: center
  :width: 90%

.. figure:: ../_static/nsca.png
  :align: center
  :width: 90%

  Images from nagios.org documentation site

Active: NRPE
------------

.. image:: ../_static/activechecks.png
  :align: right
  :width: 30%

* Active checks are:

  * Initiated by Nagios process
  * Run on a regularly scheduled basis

* Nagios server uses ``check_nrpe`` plugin to access remote host
* Remote host runs ``nrpe`` daemon
* Configuration is typically restricted to access only from nagios host
* Security implications should be considered

Problems with Active checks
---------------------------

What kind of problems would we have?

.. rst-class:: build

* If the host is unresponsive, all the checks go down at once
* How do you scale with thousands of hosts? (relies on a central server)
* Requires a service to be listening on the host (security concerns)

Passive: NSCA
-------------

.. image:: ../_static/passivechecks.png
  :align: right
  :width: 30%

* Passive checks are:

  * Initiated and performed by external applications/processes on remote server
  * Results are submitted to Nagios for processing

* NSCA daemon running on Nagios server listens for connections from passive
  hosts
* Remote host uses ``send_nsca`` which sends output to NSCA daemon running on
  Nagios server

When are Passive checks useful?
-------------------------------

* Asynchronous nature of a service that can't be checked via polling easily
* Located behind a firewall

CheckMK
-------

.. image:: ../_static/check_mk.png
  :align: right

`Check_MK`_ is an extension to Nagios that allows more flexibility checking
servers.

* Uses a mixture of passive and active checks to offload work from the Nagios
  Core
* Offers Rule-based configuration and auto detection of servers
* Scales extremely well
* Excellent web frontend

.. _Check_MK: http://mathias-kettner.com/check_mk.html

CheckMK Architecture
--------------------

.. figure:: ../_static/checkmk-arch.png
  :align: center
  :width: 80%

  Image from http://mathias-kettner.com/check_mk.html

Plugins
-------

.. rst-class:: codeblock-sm

.. code-block:: console

  # Install EPEL repo first!
  $ yum install nrpe nagios-plugins*
  $ cd /usr/lib64/nagios/plugins
  $ ./check_ssh localhost
  SSH OK - OpenSSH_6.6.1 (protocol 2.0) | time=0.188930s;;;0.000000;10.000000

  $ ./check_disk -w 15% -c 10%
  DISK OK - free space: / 8223 MB (85% inode=92%); /dev 235 MB (100% inode=99%);
  /dev/shm 244 MB (100% inode=99%); /run 240 MB (98% inode=99%); /sys/fs/cgroup
  244 MB (100% inode=99%); /run/user/1000 48 MB (100% inode=99%);|
  /=1376MB;8539;9041;0;10046 /dev=0MB;199;211;0;235 /dev/shm=0MB;207;219;0;244
  /run=4MB;207;219;0;244 /sys/fs/cgroup=0MB;207;219;0;244
  /run/user/1000=0MB;40;43;0;48

  $ ./check_http -H osuosl.org
  HTTP OK: HTTP/1.1 200 OK - 40668 bytes in 0.013 second response time
  | time=0.013421s;;;0.000000 size=40668B;;;0

NRPE Configuration
------------------

.. rst-class:: codeblock-sm

.. code-block:: console

  # /etc/nagios/nrpe.conf on the remote host
  command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
  command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
  command[check_hda1]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% \
    -p /dev/hda1

  # Command ran on the nagios server
  check_nrpe -H remotehost.example.org -c check_load

  # Testing it on a local machine
  $ systemctl start nrpe
  $ /usr/lib64/nagios/plugins/check_nrpe -H 127.0.0.1 -c check_load
  OK - load average: 0.04, 0.13, 0.07|load1=0.040;15.000;30.000;0;
  load5=0.130;10.000;25.000;0; load15=0.070;5.000;20.000;0;

Nagios Configuration Overview
-----------------------------

.. figure:: ../_static/nagiosconfig.png
  :align: center
  :width: 65%

  Nagios configuration visualized

Nagios Config components
------------------------

* Main configuration file: ``/etc/nagios/nagios.cfg``

  * Configures how the daemon operates

* Resource file(s): User defined macros (i.e. notification commands)
* Object definition files

  * Define ``hosts``, ``services``, ``hostgroups``, ``contacts``,
    ``contactgroups``, ``commands``

* CGI configuration file: How the web interface is setup

Object definitions
------------------

.. code-block:: console

  # Host definition
  define host {
    host_name      foo
    alias          foo.example.org
    address        10.0.0.100
    use            generic-host
    hostgroups     nrpe-hosts,ping-hosts
    contact_groups admins
  }

  # Service definition
  define service {
    use                 generic-service
    hostgroup_name      nrpe-hosts
    service_description SSH
    check_command       check_ssh
  }

Resources
---------

* `Nagios Core Documentation`__

.. __: http://nagios.sourceforge.net/docs/nagioscore/3/en/toc.html
