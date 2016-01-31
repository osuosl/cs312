.. _10_nfs_ldap_email:

NFS, LDAP, Email
================

NFS: Network File System
========================

NFS Basics
----------

* Share files over the network
* Originally created by Sun Microsystems in 1984
* Performance & Security concerns
* Most commonly used share protocol on Linux

NFS versions
------------

**NFSv2**
  Released in 1989 and only used UDP. In addition had 32bit filesize
  limitations as well as performance issues. Should not be used today.
**NFSv3**
  Released in 1995, has support for either UDP or TCP and improves performance,
  large file support and other various fixes on the protocol.
**NFSv4**
  Released in 2000, only supports TCP and was a major overhaul of the protocol.
  Version 4.1 was released in 2010 to provide support for clustered deployments.
  Most servers should be using at least v3 or v4 today.

NFS v4 major improvements
-------------------------

* Better support for using NFS with firewalls and NAT networks
* Stateful operation
* Strong, integrated security
* Support for replication and migration
* Support for both Linux and Windows clients
* Access Control List (ACL) support
* Good performance even on low-bandwidth networks

NFS: Stateless vs. Stateful
---------------------------

**Version 2 & 3**
  * Stateless
  * Server cannot track which clients have a volume mounted
  * Uses a cookie
**Version 4**
  * Stateful
  * When the server fails, client assists in the recovery
  * Returning server waits for clients before permitting new operations and
    locks
  * Does not use the cookie system

NFS: Security
-------------

* V2/V3 are generally viewed as inherently insecure
* Originally designed with no security in mind
* V4 introduced much improvements

.. csv-table::
  :widths: 5, 10

  ``AUTH_NONE``, non authentication
  ``AUTH_SYS``, UNIX-style user and group access control
  ``RPCSEC_GSS``, "a powerful flavor that ensures integrity and privacy in
  addition to authentication"

Kerberos integration provides the additional layer of security in V4.

NFS: Server-side daemons
------------------------

*On CentOS 7 machines*

``nfs``
  NFS server and appropriate RPC services
``nfslock``
  Mandatory service that starts the appropriate RPC processes allowing NFS
  clients to lock files on the server
``rpcbind``
  Accepts port reservations from local RPC services. Not used with NFSv4.
``rpc.mountd``
  This process is used by an NFS server to process ``MOUNT`` requests from NFSv3
  clients.

NFS: Server-side daemons
------------------------

``rpc.nfsd``
  Allows explicit NFS versions and protocols the server advertises to be defined
``lockd``
  Implements the Network Lock Manager (NLM) protocol, which allows NFSv3 clients
  to lock files on the server
``rpc.statd``
  Implements the Network Status Monitor (NSM) RPC protocol, which notifies NFS
  clients when an NFS server is restarted without being gracefully brought down.

NFS: Server-side daemons
------------------------

``rpc.rquotad``
  Provides user quota information for remote users
``rpc.idmapd``
  Provides NFSv4 client and server upcalls, which map between on-the-wire NFSv4
  names (strings in the form of ``user@domain``) and local UIDs and GIDs

The ``/etc/exports`` Configuration file
---------------------------------------

Controls which file systems are exported to remote hosts and specifies options.
It follows the following syntax rules:

* Blank lines are ignored
* To add a comment, start a line with the hash mark (``#``)
* You can wrap long lines with a backslash (``\``)
* Each exported file system should be on its own individual line
* Any lists of authorized hosts placed after an exported file system must be
  separated by space characters
* Options for each of the hosts must be placed in parentheses directly after the
  host identifier, without any spaces separating the host and the first
  parenthesis

``/etc/exports``
----------------

::

  export host(options)
  # multiple hosts
  export host1(options) host2(options) host3(options)

``export``
  The directory being exported
``host``
  The host or network to which the export is being shared
``options``
  The options to be used for ``host``

See ``man exports`` for more options

``/etc/exports`` -- Hostname formats
------------------------------------

**Single Machine**
  A fully-qualified domain name (that can be resolved by the server), hostname
  (that can be resolved by the server), or an IP address.
**Series of machines specified with wildcards**
  Use the ``*`` or ``?`` character to specify a string match. Wildcards are not
  to be used with IP addresses. Does not include sub-domains of a wildcard.

``/etc/exports`` -- Hostname formats
------------------------------------

**IP networks**
  Use ``a.b.c.d/z``, where ``a.b.c.d`` is the network and ``z`` is the number of
  bits in the netmask (for example ``192.168.0.0/24``)
**Netgroups**
  Use the format ``@group-name``, where group-name is the NIS netgroup name.

``/etc/exports`` -- Default options
-----------------------------------

``ro``
  The exported file system is read-only.
``sync``
  The NFS server will not reply to requests before changes made by previous
  requests are written to disk. To enable asynchronous writes instead, specify
  the option ``async``.
``wdelay``
  The NFS server will delay writing to the disk if it suspects another write
  request is imminent.
``root_squash``
  This prevents root users connected remotely (as opposed to locally) from
  having root privileges; instead, the NFS server will assign them the user ID
  ``nfsnobody``.

``/etc/exports`` -- Gotcha
--------------------------

These do not mean the same thing!

::

  /data foo.example.com(rw)
  /data foo.example.com (rw)

.. rst-class:: build

* First line allows only users from ``foo.example.com`` read/write access to the
  ``/data`` directory
* Second line allows users from ``foo.example.com`` to mount the directory as
  read-only (the default), while the rest of the world can mount it read/write

Discovering NFS Exports
-----------------------

First, on any server that supports NFSv2 or NFSv3, use the ``showmount``
command:

.. code-block:: bash

  $ showmount -e foo.example.com
  Export list for foo.example.com
  /data/foo
  /data/bar

Second, on any server that supports NFSv4, mount / and look around:

.. code-block:: bash

  $ mount foo.example.com:/ /mnt/
  $ cd /mnt
  data
  $ ls data
  foo
  bar

LDAP: Lightweight Directory Access Protocol
===========================================

Email Servers
=============

Resources
---------

* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html-single/Storage_Administration_Guide/index.html#ch-nfs
