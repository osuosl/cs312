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

Basic config
------------

.. rst-class:: codeblock-sm

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

  defaults
      mode                    http
      log                     global
      option                  httplog
      option                  dontlognull
      option                  http-server-close
      option                  forwardfor except 127.0.0.0/8
      option                  redispatch
      retries                 3
      timeout http-request    10s
      timeout queue           1m
      timeout connect         10s
      timeout http-keep-alive 10s
      timeout check           2s
      maxconn                 3000
