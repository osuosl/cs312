.. _20_docker_and_systemd:

Docker & SystemD
================


Dockerfiles
-----------

Dockerfiles have a fairly simple syntax of the form:

.. code-block:: none

    # This is a comment!
    INSTRUCTION arguments

If ``FROM`` is the first instruction, it will use another container
as a base:

.. code-block:: none

    FROM ubuntu:latest
    # do more stuff

Dockerfiles
-----------

.. csv-table::
   :header: Instruction,Explanation

   FROM,The container to build from.
   MAINTAINER,Lets you set the author metadata.
   RUN,Runs command inside the docker image that is being built.
   CMD,The command to run for ``docker run`` after container is built. Only one allowed.
   EXPOSE,Ports to expose for when docker links are being used. Does not expost ports to the host.

Dockerfiles
-----------

.. csv-table::
   :header: Instruction,Explanation

   ENV,Sets environment variables in the container
   ADD,Copies new files into the container. Allows input to be compressed or urls
   COPY,Like ADD. No use of urls or compressed archives
   ENTRYPOINT,Command for ``docker run`` to default to; ``CMD`` is appended.

Dockerfiles
-----------

.. csv-table::
   :header: Instruction,Explanation

   VOLUME,Used for mount points
   WORKDIR,Default working dir for other commands
   ONBUILD,Trigger when container is used as a base for other containers.

Example Dockerfile
------------------

Lets build an example Dockerfile that installs ``znc``, an IRC bouncer.

.. code-block:: none

    FROM centos
    MAINTAINER cs312@osuosl.org # Change your email here

    RUN yum update -y
    RUN yum install -y epel-release
    
    RUN yum install -y znc

    <snip>

Example Dockerfile
------------------

This is a good start, but we should also:

* Expose the znc port
* Allow a user to insert their own znc config
* Expose the znc dir as a volume
* Give the container a default cmd to run.

.. code-block:: none

    <snip>
    EXPOSE 6667
    VOLUME ["/var/lib/znc"]
    CMD ["znc", "-f"]


Example Dockerfile
------------------

Assuming we have a ``.znc`` dir in ``/home/core/znc``, we can build and run our Dockerfile!

.. code-block:: none

    $ docker build -t cs312/znc .
    $ docker run -d -v /home/core/znc:/var/lib/znc -p 6667:6667 cs312/znc

Example Dockerfile
------------------

What happens when our server reboots? We lose our container! Lets fix this by adding a SystemD
unit file and running it with fleet:

.. code-block:: none

    [Unit]
    Description=znc service
    BindsTo=znc.service

    [Service]
    ExecStartPre=-/usr/bin/docker kill cs312/znc
    ExecStartPre=-/usr/bin/docker rm cs312/znc
    ExecStart=/usr/bin/docker run --rm --name znc -d -v /home/core/znc:/var/lib/znc -p 6667:6667 cs312/znc
    ExecStop=/usr/bin/docker stop cs312/znc

Example Dockerfile
------------------

Make sure etcd and fleet are running::

    $ systemctl start etcd
    $ systemctl start fleet
    $ fleetctl list-machines
    MACHINE		IP		METADATA
    200ab8b3... 	162.243.132.158	-

Add the service to fleet and start it::

    $ fleetctl submit znc
    $ fleetctl load znc
    Unit znc.service loaded on 200ab8b3.../162.243.132.158
    $ fleetctl start znc
    Unit znc.service launched on 200ab8b3.../162.243.132.158

Example Dockerfile
------------------

Check the logs::

    $ fleetctl journal znc

Fleet & Etcd
------------

Note that fleetctl doesn't enable the znc service on boot, because
if this machine goes down, a fleet will start it on a new machine.

Obviously, this is problematic if you only have one machine in your fleet.

