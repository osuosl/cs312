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
~~~~~~~

* Relatively new init system
* Started at RedHat

How does it work?
~~~~~~~~~~~~~~~~~

* Composed of units with varying types

  - service, socket, device, mount, automount, swap, target, path, timer, slice, scope

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
