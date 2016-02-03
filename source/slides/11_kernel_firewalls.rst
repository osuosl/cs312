.. _11_kernel_firewalls:

Kernel / Firewalls
==================

Linux Kernel
============

Modules
-------

The Linux kernel is module and extended via dynamically-loaded *kernel modules*

Modules can provide:

* Device drivers which add support for hardware
* Support for a filesystem such as ``btrfs``
* Enable new features in the kernel such as ``iptables`` filters

Modules
-------

Modules typically:

* Take parameters which allow you to customize their behavior
* Are automatically loaded by various mechanisms when the conditions call for it

Listing modules
---------------

.. rst-class:: codeblock-sm

::

  $ lsmod
  Module                  Size  Used by
  ext4                  578819  1
  virtio_blk             18156  3
  virtio_net             28024  0
  virtio_pci             22913  0
  virtio_ring            21524  4 virtio_blk,virtio_net,virtio_pci,virtio_balloon
  virtio                 15008  4 virtio_blk,virtio_net,virtio_pci,virtio_balloon

* Name of the kernel module currently loaded into memory
* Amount of memory the modules uses
* Sum total of processes that are using the module and the other modules that
  depend on it
* List of names of the modules that depend on it

Information about modules
-------------------------

.. rst-class:: codeblock-sm

::

  $ modinfo virtio-net
  filename:       /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/net/virtio_net.ko
  license:        GPL
  description:    Virtio network driver
  rhelversion:    7.2
  srcversion:     01F9C1F5B30CDC842D66920
  alias:          virtio:d00000001v*
  depends:        virtio,virtio_ring
  intree:         Y
  vermagic:       3.10.0-327.4.5.el7.x86_64 SMP mod_unload modversions
  signer:         CentOS Linux kernel signing key
  sig_key:        10:5D:A1:3D:CA:AA:74:AE:50:00:17:E7:D5:2C:DA:9B:7C:C5:10:93
  sig_hashalgo:   sha256
  parm:           napi_weight:int
  parm:           csum:bool
  parm:           gso:bool

Loading a module
----------------

.. rst-class:: codeblock-sm

::

  $ modprobe -v fcoe
  insmod /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/scsi/scsi_tgt.ko
  insmod /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/scsi/scsi_transport_fc.ko
  insmod /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/scsi/libfc/libfc.ko
  insmod /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/scsi/fcoe/libfcoe.ko
  insmod /lib/modules/3.10.0-327.4.5.el7.x86_64/kernel/drivers/scsi/fcoe/fcoe.ko

* ``modprobe`` attempts to the load module and all its dependencies
* ``insmod`` also loads modules, but does not resolve dependencies

Unloading a module
------------------

.. rst-class:: codeblock-sm

::

  $ modprobe -v -r fcoe
  rmmod fcoe
  rmmod libfcoe
  rmmod libfc
  rmmod scsi_transport_fc
  rmmod scsi_tgt

Will fail if:

* A process is using the ``fcoe`` module
* A module that ``fcoe`` directly depends on
* Any module that ``fcoe``, through the dependency tree, depends on indirectly

Setting module parameters
-------------------------

::

  modprobe module_name [parameter=value]

Some notes to consider:

* You need to unload the module to update module parameters
* **Most** parameters aren't dynamically changeable
* **Some** parameters can be changed dynamically (see ``sysfs`` slide)

Persistent module loading
-------------------------

``/etc/modules-load.d/fcoe.conf``

.. code-block:: bash

  # Load fcoe module at boot
  fcoe

Managed via ``systemd-modules-load`` service

Persistent parameter loading:

``/etc/modprobe.d/virtio-net.conf``

.. code-block:: bash

  # Disable csum parameter
  options virtio-net csum=N

sysfs
-----

* Virtual file system that exports information about various kernel subsystems,
  hardware devices, and device drivers
* Similar functionality to sysctl, but implemented as a filesystem

sysfs
-----

.. rst-class:: codeblock-very-small

.. csv-table::
  :widths: 5, 20

  ``sys/block/``, "all known block devices such as ``hda/`` ``ram/`` ``sda/``"
  ``sys/bus/``, "all registered buses"
  ``sys/class/``, "for each device type there is a subdirectory"
  ``sys/device/``, "all devices known by the kernel, organised by the bus they are
  connected to"
  ``sys/firmware/``, "files in this directory handle the firmware of some hardware
  devices"
  ``sys/fs/``, "files to control a file system, currently used by FUSE, a user space
  file system implementation"
  ``sys/kernel/``, "holds directories (mount points) for other filesystems such as
  debugfs, securityfs."
  ``sys/module/``, "each kernel module loaded is represented with a directory."
  ``sys/power/``, "files to handle the power state of some hardware"

Writing to sysfs
----------------

Some parameters are writable, such as module parameters (sometimes):

.. rst-class:: codeblock-sm

::

  $ ll /sys/module/fcoe/parameters/
  total 0
  -rw-r--r--. 1 root root 4096 Feb  3 19:22 ddp_min
  -rw-r--r--. 1 root root 4096 Feb  3 19:22 debug_logging

  $ cat /sys/module/fcoe/parameters/debug_logging
  0
  $ echo 1 > /sys/module/fcoe/parameters/debug_logging
  $ cat /sys/module/fcoe/parameters/debug_logging
  1
  $ ll /sys/module/virtio_net/parameters/
  total 0
  -r--r--r--. 1 root root 4096 Feb  3 19:17 csum
  -r--r--r--. 1 root root 4096 Feb  3 19:17 gso
  -r--r--r--. 1 root root 4096 Feb  3 19:17 napi_weight
  $ echo Y > /sys/module/virtio_net/parameters/csum
  -bash: /sys/module/virtio_net/parameters/csum: Permission denied

sysctl
------

* ``sysctl`` is a tool which allows you to modify runtime kernel tunable
  parameters
* Visible as a virtual filesystem under ``/proc/sys``
* ``sysfs`` was created to replace parts of ``sysctl`` as it ``procfs`` was
  deemed too "chaotic"

Important subdirs:

.. rst-class:: codeblock-sm

.. csv-table::
  :widths: 5, 15

  ``fs/``, "specific filesystems filehandle, inode, dentry and quota tuning"
  ``kernel/``, "global kernel info / tuning miscellaneous stuff"
  ``net/``, "networking settings"
  ``vm/``, "memory management tuning, buffer and cache management"

Using sysctl
------------

.. code-block:: bash

  # see all variables
  sysctl -a

  # dynamically set a variable
  sysctl -w net.ipv4.ip_forward=1

  # load from a file
  sysctl -p /etc/sysctl.conf

  # load from all system files
  sysctl --system

Persistent sysctl settings:

* Save in either ``/etc/sysctl.conf`` or in ``/etc/sysctl.d/<name>.conf``
* Managed via ``systemd-sysctl.service`` on CentOS 7

Dracut
------

Control Groups
==============

Performance Tuning
==================

Firewalls
=========

Resources
---------

* https://wiki.centos.org/HowTos/Network/IPTables
* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/index.html
* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Resource_Management_Guide/index.html
* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/part-Kernel_Module_and_Driver_Configuration.html
* http://people.ee.ethz.ch/~arkeller/linux/multi/kernel_user_space_howto-2.html
* https://www.kernel.org/doc/Documentation/sysctl/README
