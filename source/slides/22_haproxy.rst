.. _22_haproxy:

HAProxy
=======

Objectives Today
----------------

1. Install and setup HAProxy
2. Setup several backends
3. Test failover with backends
4. Configure and test admin page

Create a new VM
---------------

1. Remove any prior VM instances from OpenStack (Unless you're using one for a
   HW assignment).
2. Create a new VM called ``<onid>-haproxy`` using CentOS 6.6 image

Install HAProxy
---------------

.. code-block:: bash

  $ yum install haproxy
  $ service haproxy start


Logging on HAProxy
------------------

HAProxy sends all logs via syslog by default on CentOS

::

  # /etc/haproxy/haproxy.cfg
  global
    log 127.0.0.1 local2

  defaults
    log global

Setting up logging for HAProxy
------------------------------

.. code-block:: bash

  $ vi /etc/rsyslog.conf

  # Enable UDP log server on 127.0.0.1:541 to listen for haproxy logs
  $ModLoad imudp
  $UDPServerRun 514
  $UDPServerAddress 127.0.0.1

  # Let's tell rsyslog where to log the output
  $ vi /etc/rsyslog.d/haproxy.conf

  # Add this into the file
  local2.*    /var/log/haproxy.log

  $ service rsyslog reload

`haproxy logging documentation`_

.. _haproxy logging documentation: http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#4.2-log

Global Config
-------------

::

  global
      log         127.0.0.1 local2
      chroot      /var/lib/haproxy
      pidfile     /var/run/haproxy.pid
      maxconn     4000
      user        haproxy
      group       haproxy
      daemon
      stats socket /var/lib/haproxy/stats

Defaults Config
---------------

::

  defaults
      mode                    http
      log                     global
      option                  httplog
      option                  dontlognull
      option                  http-server-close
      option                  forwardfor except 127.0.0.0/8
      option                  redispatch
      retries                 3
      timeout check           2s
      timeout client          1m
      timeout connect         10s
      timeout http-keep-alive 10s
      timeout http-request    10s
      timeout queue           1m
      timeout server          1m
      maxconn                 3000

Add Frontend/Backend
--------------------

Append the frontend and backend configuration to the ``haproxy.cfg`` file.

Try accessing the website using your VM's IP, what do you see?

::

  frontend http
      bind 0.0.0.0:80
      default_backend servers

  backend servers
      server www1 140.211.168.121:80 check
      server www2 140.211.168.130:80 check

Proxies in HAProxy
------------------

**defaults**
  Sets default parameters for all other proxy sections.

**frontend**
  Listening sockets accepting client connections.

**backend**
  Set of servers to which the proxy will connect to forward incoming connections.

**listen**
  Defines a complete proxy with its frontend and backend parts combined in one
  section. Typically useful for TCP only or for the admin port.

`Matrix of proxy keywords`_

.. _Matrix of proxy keywords: http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#4.1

Admin Panel
-----------

HAProxy provides a nice web page to display stats. To enable it, add the
following to your config and reload haproxy.

It's best to secure this port. It can be used to generate graphs as well.

::

  listen admin
      bind 0.0.0.0:22002
      mode http
      stats uri /

Testing Backends
----------------

Let's try taking down the ``www2`` backend and see what happens.

Changing the balancing algorithm
--------------------------------

::

  backend servers
      balance roundrobin
      server www1 140.211.168.121:80 check
      server www2 140.211.168.130:80 check


Adjusting the weighting
-----------------------

::

  backend servers
      balance roundrobin
      server www1 140.211.168.121:80 weight 50 check
      server www2 140.211.168.130:80 weight 100 check

