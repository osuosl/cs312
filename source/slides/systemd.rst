.. _systemd_slides:

SystemD
=======


SystemD
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
