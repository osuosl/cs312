.. _11_kernel_cgroups:

Kernel / CGroups
================

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

.. rst-class:: build

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

.. rst-class:: build

* A process is using the ``fcoe`` module
* A module that ``fcoe`` directly depends on
* Any module that ``fcoe``, through the dependency tree, depends on indirectly

Setting module parameters
-------------------------

::

  modprobe module_name [parameter=value]

Some notes to consider:

.. rst-class:: build

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

Control Groups
==============

Control Groups (cgroups)
------------------------

.. rst-class:: build

* Kernel feature that allows you to allocate resources

  * CPU Time, system memory, network bandwidth, or combinations of these
    resources

* Allows you to have fine-grained control over allocating, prioritizing,
  denying, managing and monitoring system resources.
* Provides a way to hierarchically group and label processes and apply resource
  limits on them
* Old method was using a process *niceness* value
* systemd uses cgroups heavily internally

Default cgroup hierarchies
--------------------------

systemd automatically creates a hierarchy of *slice*, *scope* and *service*
units.

.. rst-class:: codeblock-very-small

.. rst-class:: build

**Service**
  A process or a group of processes, which systemd started based on a unit
  configuration file. Services encapsulate the specified processes so that they
  can be started and stopped as a one set.
**Scope**
  A group of externally created processes. Scopes encapsulate processes that are
  started and stopped by arbitrary processes via the ``fork()`` function and
  then registered by systemd at runtime. For instance, user sessions,
  containers, and virtual machines are treated as scopes.
**Slice**
  A group of hierarchically organized units. Slices do not contain processes,
  they organize a hierarchy in which scopes and services are placed. The actual
  processes are contained in scopes or in services.

Default slices
--------------

**-.slice**
  The root slice
**system.slice**
  The default place for all system services
**user.slice**
  The default place for all user sessions
**machine.slice**
  The default place for all virtual machines and Linux containers

Visualizing systemd cgroups
---------------------------

.. rst-class:: codeblock-very-small

::

  $ systemd-cgls
  ├─1 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
  ├─user.slice
  │ └─user-1000.slice
  │   └─session-24.scope
  │     ├─16767 sshd: centos [priv]
  │     ├─16770 sshd: centos@pts/0
  │     ├─16771 -bash
  │     ├─16790 sudo su -
  │     ├─16791 su -
  │     ├─16792 -bash
  │     ├─21231 systemd-cgls
  │     └─21232 systemd-cgls
  └─system.slice
    ├─sshd.service
    │ └─2013 /usr/sbin/sshd -D
    ├─postfix.service
    │ ├─ 1106 /usr/libexec/postfix/master -w
    │ ├─ 1116 qmgr -l -t unix -u
    │ └─20585 pickup -l -t unix -u
    ├─crond.service
    │ └─484 /usr/sbin/crond -n
    ├─rsyslog.service
    │ └─461 /usr/sbin/rsyslogd -n
    └─systemd-journald.service
      └─328 /usr/lib/systemd/systemd-journald

systemd-cgtop
-------------

.. rst-class:: codeblock-sm

::

  Path                                     Tasks   %CPU   Memory  Input/s Output/s

  /                                           76    0.3   318.4M        -        -
  /system.slice/NetworkManager.service         2      -        -        -        -
  /system.slice/auditd.service                 1      -        -        -        -
  /system.slice/crond.service                  1      -        -        -        -
  /system.slice/dbus.service                   1      -        -        -        -
  /system.slice/gssproxy.service               1      -        -        -        -
  /system.slice/polkit.service                 1      -        -        -        -
  /system.slice/postfix.service                3      -        -        -        -
  /system.slice/rsyslog.service                1      -        -        -        -
  /system.slice/sshd.service                   1      -        -        -        -
  /system.slic...lice/getty@tty1.service       1      -        -        -        -
  /system.slic...ial-getty@ttyS0.service       1      -        -        -        -
  /system.slice/systemd-journald.service       1      -        -        -        -
  /system.slice/systemd-logind.service         1      -        -        -        -
  /system.slice/systemd-udevd.service          1      -        -        -        -
  /system.slice/tuned.service                  1      -        -        -        -
  /system.slice/wpa_supplicant.service         1      -        -        -        -
  /user.slice/....slice/session-24.scope       7      -        -        -        -

Cgroup Resource Controllers
---------------------------

See ``/proc/cgroups`` for all enabled controllers

.. rst-class:: codeblock-sm

.. csv-table::
  :widths: 5, 15

  ``blkio``, sets limits on input/output access to and from block devices
  ``cpu``, "uses the CPU scheduler to provide cgroup tasks an access to the CPU. It is
  mounted together with the ``cpuacct`` controller on the same mount."
  ``cpuacct``, creates automatic reports on CPU resources used by tasks in a cgroup
  ``cpuset``, "assigns individual CPUs (on a multicore system) and memory nodes to tasks in a
  cgroup"
  ``memory``, "sets limits on memory use by tasks in a cgroup, and generates automatic
  reports on memory resources used by those tasks."

Creating transient cgroups
--------------------------

The ``systemd-run`` command allows you to create and start a transient service
or scope unit::

  systemd-run --unit=name --scope --slice=slice_name command

.. csv-table::

  ``--remain-after-exit``, Leave service around until explicitly stopped
  ``--machine``, Operate on local container

Example::

  $ systemd-run --unit=toptest --slice=test top -b
  Running as unit toptest.service.

Setting parameters on cgroups
-----------------------------

The ``systemctl set-property`` command allows you to persistently change
resource control settings during application runtime::

  systemctl set-property name parameter=value

Example, limit CPU and memory usage on ``httpd.service``:

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Persistent change
  $ systemctl set-property httpd.service CPUShares=600 MemoryLimit=500M

  # Temporary change
  $ systemctl set-property --runtime httpd.service CPUShares=600 MemoryLimit=500M

Cgroups & systemd: CPU
----------------------

* The ``CPUShares`` parameter controls the ``cpu.shares`` control group parameter.
* The default value is 1024, by increasing this number you assign more CPU to
  the unit.
* Example: setting it to 2048 means that process will have 200% more cpu time
  than any other process

::

  [Service]
  CPUShares=1500

Cgroups & systemd: Memory
-------------------------

* The ``MemoryLimit`` parameter controls the ``memory.limit_in_bytes`` control
  group parameter
* Set a maximum memory using suffixes such as K, M, G T
* No default setting

::

  [Service]
  MemoryLimit=1G

Cgroups & systemd: Block I/O
----------------------------

.. rst-class:: build

``BlockIOWeight=value``
  Replace *value* with a new overall block IO weight for the executed processes.
  Choose a single value between 10 and 1000, the default setting is 1000.

``BlockIODeviceWeight=device_name value``
  Replace *value* with a block IO weight for a device specified with
  *device_name*.  Replace *device_name* either with a name or with a path to a
  device. As with ``BlockIOWeight``, it is possible to set a single weight value
  between 10 and 1000.

.. rst-class:: build

::

  [Service]
  BlockIODeviceWeight=/home/jdoe 750
  BlockIOReadBandwith=/var/log 5M

Cgroups & systemd: Block I/O
----------------------------

.. rst-class:: build

``BlockIOReadBandwidth=device_name value``
  This directive allows to limit a specific bandwidth for a unit. Replace
  *device_name* with the name of a device or with a path to a block device node,
  *value* stands for a bandwidth rate. Use K, M, G, T suffixes to specify units
  of measurement, value with no suffix is interpreted as bytes per second.
``BlockIOWriteBandwidth=device_name value``
  Limits the write bandwidth for a specified device. Accepts the same arguments
  as ``BlockIOReadBandwidth``.

Performance Tuning
==================

Tools
-----

.. rst-class:: codeblock-very-small

.. rst-class:: build

``vmstat``
  Virtual Memory Statistics tool, vmstat, provides instant reports on your
  system's processes, memory, paging, block input/output, interrupts, and CPU
  activity.
``tuned`` and ``tuned-adm``
  tuned-adm is a command line tool that provides a number of different profiles
  to improve performance in a number of specific use cases. Profiles include:
  throughput-performance, latency-performance, network-latency
  network-throughput, virtual-guest, virtual-host
``perf``
  The perf tool uses hardware performance counters and kernel tracepoints to
  track the impact of other commands and applications on your system.
``iostat``
  Provided by the ``sysstat`` package, it monitors and reports on system
  input/output device loading to help administrators make decisions about how to
  balance input/output load between physical disks.

I/O Schedulers
--------------

The I/O scheduler determines when and for how long I/O operations run on a
storage device. It is also known as the I/O elevator.

**deadline**
  The default I/O scheduler for all block devices except SATA disks.
  ``Deadline`` attempts to provide a guaranteed latency for requests from the
  point at which requests reach the I/O scheduler. This scheduler is suitable
  for most use cases, but particularly those in which read operations occur more
  often than write operations.

I/O Schedulers
--------------

**cfq**
  The default scheduler only for devices identified as SATA disks. The
  Completely Fair Queueing scheduler, ``cfq``, divides processes into three
  separate classes: real time, best effort, and idle.
**noop**
  The ``noop`` I/O scheduler implements a simple FIFO (first-in first-out)
  scheduling algorithm. Requests are merged at the generic block layer through a
  simple last-hit cache. This can be the best scheduler for CPU-bound systems
  using fast storage.

Setting the I/O Scheduler
-------------------------

* By adding as a kernel argument at boot via ``elevator=scheduler_name`` OR
* Set it for a particular storage device via ``echo cfq >
  /sys/block/hda/queue/scheduler``

TCP tuning
----------

The default maximum Linux TCP buffer sizes are usually set too small. Here are
some saner ``sysctl`` defaults for a host with a 10G NIC:

.. code-block:: bash

  # allow testing with buffers up to 64MB
  net.core.rmem_max = 67108864
  net.core.wmem_max = 67108864
  # increase Linux autotuning TCP buffer limit to 32MB
  net.ipv4.tcp_rmem = 4096 87380 33554432
  net.ipv4.tcp_wmem = 4096 65536 33554432
  # increase the length of the processor input queue
  net.core.netdev_max_backlog = 30000
  # recommended default congestion control is htcp
  net.ipv4.tcp_congestion_control=htcp
  # recommended for hosts with jumbo frames enabled
  net.ipv4.tcp_mtu_probing=1

Resources
---------

* `RHEL 7 Performance Tuning Guide`__
* `RHEL 7 Resource Management Guide`__
* `RHEL 7 Kernel Management Guide`__
* `Kernel user space HOWTO`__
* `Linux Kernel sysctl documentation`__

.. __: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/index.html
.. __: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Resource_Management_Guide/index.html
.. __: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/part-Kernel_Module_and_Driver_Configuration.html
.. __: http://people.ee.ethz.ch/~arkeller/linux/multi/kernel_user_space_howto-2.html
.. __: https://www.kernel.org/doc/Documentation/sysctl/README
