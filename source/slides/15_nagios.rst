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

  * Daemons that actually execute the plugin on a server
  * NRPE: Active checking daemon
  * NSCA: Passive checking daemon

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

Examples
--------

Potential issues with Nagios
----------------------------

HW2 Review
==========


