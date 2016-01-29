.. _09_linux_networking:

Linux Networking
================

Summary
-------

* Linux Networking Commands
* Advanced Linux Networking
* Configuring networking

Linux Networking Commands
-------------------------

Common commands:

.. csv-table::
  :widths: 5, 15

  ``ip``, "Command to show and manipulate network devices and routing"
  ``ifconfig``, "Deprecated command for configuring network devices"
  ``route``, "Deprecated command for managing network routes"
  ``ifup/down``, "Bring a network interface up or down"
  ``ss``, "Show socket connections"
  ``netstat``, "Deprecated command for showing network connection"
  ``arp``, "Deprecated command for showing ARP information"

``ip``
------

* Global command to manage networking
* Common sub-commands:

  ``address``
    protocol (IP or IPv6) address on a device
  ``link``
    network device
  ``route``
    routing table entry

* Common Actions: ``add``, ``delete``, ``show`` (or ``list``)
* Can use short cuts for sub-commands

Configuring an IP address
-------------------------

.. code-block:: bash

  # Assign an IP address to a specific interface
  ip addr add 192.168.50.5 dev eth1

  # Set an IP with a specific netmask
  ip addr add 192.168.50.5/23 dev eth1

  # Remove an IP address (best to use full CIDR)
  ip addr del 192.168.50.5/23 dev eth1

  # Show all interfaces
  ip addr show

  # Show a specific interface
  ip addr show dev eth1

This replaces ``ifconfig``.

Configuring network interfaces
------------------------------

.. code-block:: bash

  # Bring an interface up
  ip link set eth1 up

  # Bring an interface down
  ip link set eth1 down

  # Set the MTU
  ip link set eth1 mtu 9000

This replaces ``ifconfig``.

Configuring the routing information
-----------------------------------

.. code-block:: bash

  # Adding the default gateway
  ip route add default via 192.168.50.1

  # Add a static route
  ip route add 10.20.10.0/24 via 192.168.50.1

  # Remove a static route
  ip route del 10.20.10.0/24

  # Show route table
  ip route show

This replaces ``route``.

ARP table management
--------------------

.. code-block:: bash

  # Show ARP table
  ip neigh

  # Show verbose ARP table
  ip -s neigh

  # Add new ARP table entry
  ip neigh add 192.168.50.20 lladdr 1:2:3:4:5:6 dev eth1

  # Remove ARP table entry
  ip neigh del 192.168.50.20 dev eth1

This replaces ``arp``.

Showing network socket information
----------------------------------

.. code-block:: bash

  # Show all network stats
  ss

  # Show all TCP network stats without DNS lookups
  ss -nt

  # Show multicast addresses
  ip maddr

This replaces ``netstat``.

Networking on Red Hat
---------------------

``NetworkManager``
  The default networking daemon on CentOS 7
``nmtui``
  A simple curses-based text user interface (TUI) for ``NetworkManager``
``nmcli``
  A command-line tool provided to allow users and scripts to interact with
  ``NetworkManager``

Configuring networking in Red Hat
---------------------------------

``/etc/sysconfig/network-scripts``
  Interface specific information is stored in ``ifcfg`` files in this directory
``/etc/sysconfig/network``
  A file that contains global network settings (i.e. VPNs, etc).

``/etc/sysconfig/network-scripts/ifcfg-eth0``

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Static
  DEVICE=eth0
  BOOTPROTO=none
  ONBOOT=yes
  PREFIX=24
  IPADDR=10.0.1.27

  # DHCP
  DEVICE=eth0
  BOOTPROTO=dhcp
  ONBOOT=yes

Notifying NetworkManager of changes
-----------------------------------

NetworkManager needs to be made aware of the change by running::

  nmcli connection reload

Or if you only want it to change the file you changed::

  nmcli con load /etc/sysconfig/network-scripts/ifcfg-eth0

Bringing the interface up:

.. code-block:: bash

  ifup eth0

  # OR

  nmcli con up eth0

Consistent Network Device Naming
--------------------------------

.. rst-class:: build

* Historically devices were named ``eth0``, ``eth1``, etc
* Ordering was unpredictable and non-deterministic
* Kernel internally names interfaces
* Modern Linux distributions support a new number scheme

  * Names devices based on firmware, topology and location information
  * Provides names that are fully automatic and predictable (even if hardware is
    added or removed)
  * Disadvantage, its harder to read them (``eth0`` vs. ``enp5s0``)

Device Naming Hierarchy
-----------------------

By default, ``systemd`` uses the following policies for naming:

.. rst-class:: build

#. Using Firmware or BIOS index numbers for on-board devices (i.e. ``eno1``)
#. Using Firmware or BIOS provided PCI Express hotplug slot index numbers (i.e.
   ``ens1``)
#. Using physical location of the connector of the hardware (i.e. ``enp2s0``)
#. Using interfaces MAC address (i.e. ``enx78e7d1ea46da``)
#. Fallback to unpredictable kernel naming scheme (i.e. ``eth0``)

.. rst-class:: build

*Can be disabled with* ``net.ifnames=0 biosdevname=0`` *set at boot*

Predictable naming formats
--------------------------

Two character prefixes:

.. csv-table::

  ``en``, Ethernet
  ``wl``, "Wireless (WLAN)"
  ``ww``, "Wireless wide network (WWAN)"

Predictable naming formats
--------------------------

Device Name Types:

``o<index>``
  on-board device index number
``s<slot>[f<function>][d<dev_id>]``
  hotplug slot index number
``x<MAC>``
  MAC address
``p<bus>s<slot>[f<function>][d<dev_id>]``
  PCI geographical location

Example:: ``enP2p1s0f4``

Advanced Networking
-------------------

.. rst-class:: build

**Ethernet Bonding**
  Bind multiple interfaces into a single bonded, channel. Channel bonding
  enables two or more network interfaces to act as one, simultaneously
  increasing the bandwidth and providing redundancy.
**Networking Teaming**
  Newer implementation of ethernet bonding. Provides an API interface which
  user-space applications can use.

Advanced Networking
-------------------

.. rst-class:: build

**Network Bridges**
  Link-layer device which forwards traffic between networks based on MAC
  addresses. A software bridge can be used within a Linux host in order to
  emulate a hardware bridge, for example in virtualization applications for
  sharing a NIC with one or more virtual NICs.
**VLAN tagging**
 Using tagged VLANs on interfaces.

Resources
---------

* `Red Hat Enterprise Networking Guide`__
* `ip command cheat sheet`__

.. __: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/index.html
.. __: https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf

Class Announcements
-------------------

* Midterm #1 returned on Monday
* HW#2 Assigned today
* Project #1 Due Monday
