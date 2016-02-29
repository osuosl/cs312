.. _20_containers:

Containers
==========

What are Containers?
--------------------

  *A method of isolating multiple user-space environments using the system
  kernel instead of a hypervisor*

* Operating System level virtualization
* Provides little to know overhead
* Allows to contain software applications in a secure manner
* Also allows to limit resources per application easily with cgroups
* Does not fully emulate the operating system like hypervisors do

Chroot
------

  *Changes the apparent root directory for the current running process and its
  children*

* Provides filesystem isolation
* Restrict process access to the rest of the system
* Useful for creating testing and development environments
* Allows you to run software in a separated environment from your system
* Useful during recovery of a system
* Fairly easy to break out of chroots
* Very limited on features

Components of Linux Containers
------------------------------

Uses integrated features included in the Linux Kernel. Basically chroot on
steroids.

**Two components are required in Linux to make containers work:**

.. rst-class:: build

**CGroups**
  Process resource limiting, prioritization, accounting and control
**Namespace Isolation**
  Groups of processes are separated in a way which they cannot see resources in
  other groups

Namespace Isolation
-------------------

.. rst-class:: build

**PID Namespace**
  Provides isolation in PIDs, list of processes and their details. The new
  namespace is isolated from other namespaces with their own different set of
  PIDs.
**Network Namespace**
  Isolates NICs (virtual or physical), iptables firewall rules and routing
  tables. They are connected using virtual ethernet devices (``veth``).
**UTS Namespace**
  Allows changing the hostname.

Namespace Isolation
-------------------

.. rst-class:: build

**Mount Namespace**
  Allows creating a different file system layout, or making mount points
  read-only.
**IPC Namespace**
  Isolates the inter-process communication between namespaces.
**User namespace**
  Isolates user IDs between namespaces.

Implementations of Containers
-----------------------------

* Docker
* LXC
* FreeBSD jail
* Solaris Zones
* Linux-VServer
* OpenVZ

Docker
------

  *Open source project that automates deployments of applications inside of
  Linux containers*

* Started as an internal project within dotCloud, a PaaS company
* Released as opensource in March 2013
* First version used LXC for the execution environment
* Dropped LXC in favor of libcontainer in March of 2014 (now known as runc)

Install and run Docker
----------------------

.. rst-class:: codeblock-sm

.. code-block:: console

  $ yum install docker
  $ systemctl start docker

  # Hello world
  $ docker run centos /bin/echo 'Hello world'

  # Interactive container
  $ docker run -t -i ubuntu /bin/bash
  root@f9a237bdde9f:/#

  # Daemonized Hello World
  $ docker run -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
  45637cb38ddcfe4b9693fecd956e865167798dab435c55aae712cf6b83f62ecd

  # Show running containers
  $ docker ps

  # See output from container
  $ docker logs <container name>

  # Stop container
  $ docker stop <container name>

Dockerfiles
-----------

``Dockerfiles`` are configuration files for Docker and have a fairly simple
syntax of the form:

.. code-block:: docker

  # This is a comment!
  INSTRUCTION arguments

If ``FROM`` is the first instruction, it will use another container
as a base:

.. code-block:: docker

  FROM centos:latest
  # do more stuff

Dockerfiles
-----------

.. csv-table::
   :header: Instruction,Explanation
   :widths: 5, 15

   ``FROM``,The container to build from the `Docker Hub`__.
   ``MAINTAINER``,Lets you set the author metadata.
   ``RUN``,Runs command inside the docker image that is being built.
   ``CMD``,"The command to run for ``docker run`` after container is built.
   **Only one allowed**."
   ``EXPOSE``,"Ports to expose for when docker links are being used. Does not
   expose ports to the host."
   ``ENV``,Sets environment variables in the container


.. __: https://hub.docker.com/

Dockerfiles
-----------

.. csv-table::
   :header: Instruction,Explanation
   :widths: 5,15

   ``ADD``,"Copies new files into the container. Allows input to be compressed
   or urls"
   ``COPY``,Like ``ADD``. No use of urls or compressed archives
   ``ENTRYPOINT``,"Command for ``docker run`` to default to; ``CMD`` is
   appended."
   ``USER``,User to run all subsequent commands as
   ``VOLUME``,"Creates a mount point with the specified name and marks it as
   holding externally mounted volumes from native host or other containers"
   ``WORKDIR``,Default working dir for other commands
   ``ONBUILD``,Trigger when container is used as a base for other containers.

Example Dockerfile
------------------

Lets build an example ``Dockerfile`` that serves a simple python-based echo
server.

.. rst-class:: codeblock-sm

.. code-block:: docker

  FROM centos
  MAINTAINER cs312@osuosl.org # Change your email here

  ADD http://ilab.cs.byu.edu/python/code/echoserver-simple.py /echoserver-simple.py

Example Dockerfile
------------------

This is a good start, but we should also:

.. rst-class:: build

* Expose the echo server port
* Give the container a default cmd to run.

.. rst-class:: build

.. rst-class:: codeblock-sm

.. code-block:: docker
  :emphasize-lines: 5-6

  FROM centos
  MAINTAINER cs312@osuosl.org # Change your email here

  ADD http://ilab.cs.byu.edu/python/code/echoserver-simple.py /echoserver-simple.py
  EXPOSE 50000
  CMD ["python", "/echoserver-simple.py"]

Example Dockerfile
------------------

.. code-block:: console

  $ docker build -t cs312/echo .
  $ docker run -d -p 50000:50000 cs312/echo
  $ yum install nc
  $ nc localhost 50000
  foo
  foo

Docker + systemd
----------------

What happens when our server reboots? We lose our container! Lets fix this by
adding a systemd unit file:

::

  [Unit]
  Description=echo service
  BindsTo=echo.service

  [Service]
  ExecStartPre=-/bin/docker kill echo
  ExecStartPre=-/bin/docker rm echo
  ExecStart=/bin/docker run --name echo -p 50000:50000 cs312/echo
  ExecStop=/bin/docker stop echo

Resources
---------

* https://blog.engineyard.com/2015/linux-containers-isolation
* https://docs.docker.com/engine/reference/builder/
