.. _15_nagios:

Monitoring: Nagios
==================

Monitoring Basics
-----------------


* What types of resources should we monitor?

.. rst-class:: build

  * Load
  * Disk usage
  * Memory/Swap usage
  * Services: ssh, httpd, etc

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

* Core server process

  * Core logic for monitoring
  * Keeps track of service states
  * Starts service checks

* CGI Web interface

  * Simple web interface which connects to the core server process via sockets

Components of Nagios
--------------------

* Plugins

  * Scripts written to gather monitoring information
  * Typically written in Perl, but can be written in about anything
  * Has an API that you follow to create your own plugin

* NRPE/NSCA

  * Daemons that handle remote checks
  * NRPE: Active checking daemon
  * NSCA: Passive checking daemon (just listens for data)

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

::

  # Install EPEL repo first!
  $ yum install nrpe nagios-plugins*
  $ cd /usr/lib64/nagios/plugins
  $ ./check_ssh localhost
  SSH OK - OpenSSH_5.3 (protocol 2.0) | time=0.120962s;;;0.000000;10.000000

  $ ./check_disk -w 15% -c 10%
  DISK OK - free space: / 8556 MB (89% inode=94%); /dev/shm 245 MB (100% inode=99%);|
  /=978MB;8539;9041;0;10046 /dev/shm=0MB;208;220;0;245

  $ ./check_http -H osuosl.org
  HTTP OK: HTTP/1.1 200 OK - 20687 bytes in 0.008 second response time
  |time=0.007503s;;;0.000000 size=20687B;;;0

NRPE Configuration
------------------

.. rst-class:: codeblock-sm

::

  # In nrpe.conf on the remote host
  command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
  command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
  command[check_hda1]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% \
    -p /dev/hda1

  # Command ran on the nagios server
  check_nrpe -H remotehost.example.org -c check_load

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

::

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

* http://nagios.sourceforge.net/docs/nagioscore/3/en/toc.html

HW2 Review
==========

* Class Average: 13.83
* Median: 15.50

Difficult Questions
-------------------


Give the command to extend the logical volume described in #1 by 200GB to make
it a total of 300GB in size.

.. rst-class:: build

  ::

    lvextend -L +200G /dev/vg_cs312/data

Kickstart question:

.. rst-class:: build

  .. code-block:: bash

    part /boot --fstype=ext4 --size=512
    part pv.01 --grow --size=100
    volgroup vg_cs312 pv.01
    logvol swap --vgname=vg_cs312 --name=swap --fstype=swap --size=1024
    logvol / --vgname=vg_cs312 --name=root --fstype=ext4 --grow --size=100
    services --enabled=httpd
    %packages --nobase
    sudo
    bash-completion
    httpd
    %end

Difficult Questions
-------------------

Install and setup jenkins in an openstack virtual machine. Describe
the process and the exact commands you ran to setup jenkins.

.. rst-class:: build

  * Describe steps after installing it?
  * Setup Security? Setup User?
