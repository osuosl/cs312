.. _19_loadbalancer:

Load Balancers / HAProxy
========================

Load Balancer Definition
------------------------

.. rst-class:: build

* Distributes a workload across multiple computing resources
* Typically used for HTTP/HTTPS sites, but can be used for about anything
* "*Scale out*" and maximize throughput
* Offer redundancy automatically

Types
-----

.. rst-class:: build

**Round Robin DNS**
  Assign multiple IP addresses to the same domain name. Simple and easy to
  implement but doesn't allow for automatic fail over.

**Software TCP/UDP load balancing**
  Uses the OSI network layer to provide an entry point for traffic and then uses
  logic to pass the traffic to backend nodes. HAProxy, Nginx, Apache and Varnish
  can all act as a load balancer.

**Hardware TCP/UDP load balancing**
  Proprietary hardware that provides the same features (and usually more) than
  the software load balancing tools. They typically can provide more throughput
  and offer SSL off loading (which is critical for high traffic sites).

Round Robin DNS (RR DNS)
------------------------

* Multiple IP addresses to the same domain
* Client resolver usually picks the first IP
* Depending on the implementation of the client resolver, this can be somewhat
  random or not.
* Some resolvers always use alphabetical ordering
* DNS Caching and Time-To-Live (TTL) issues
* What happens if a site goes down? How does it affect troubleshooting?

Split-view DNS
--------------

Split-view DNS offers a simple way to split traffic up based on the IP address
of the client's source DNS server. In the case of ``ftp.osuosl.org``, we split
the DNS based on what IPs are routed via Internet2. When used in combination
with Round Robin DNS, it can be a simple and useful load balancing tool.

.. rst-class:: codeblock-sm

.. code-block:: console

  # Querying on campus gives us one server
  $ host ftp.osuosl.org
  ftp.osuosl.org has address 140.211.166.134

  # Querying an OpenDNS server, gives us a RR DNS answer
  $ host ftp.osuosl.org 208.67.222.222
  Using domain server:
  Name: 208.67.222.222
  Address: 208.67.222.222#53
  Aliases:

  ftp.osuosl.org has address 64.50.233.100
  ftp.osuosl.org has address 64.50.236.52

Layer 4 vs Layer 7 load balancing
---------------------------------

.. rst-class:: build

**Linux Virtual Server (LVS)**
  Layer 4 kernel-based load balancing. Typically only works on a connection
  level but can offer fast balancing. More complicated to setup and manage.

**HAProxy**
  Layer 7 user-space load balancing. Can use both connection and inspect
  packets. Allows you to modify packets or direct traffic based on packets.
  Somewhat easier to setup and manage.

Scheduling Algorithms
---------------------

*Taken from the HAProxy documentation*

.. rst-class:: build

**Round Robin**
  Each server is used in turns, according to their weights.  This is the
  smoothest and fairest algorithm when the server's processing time remains
  equally distributed. This algorithm is dynamic, which means that server
  weights may be adjusted on the fly for slow starts for instance.

Scheduling Algorithms
---------------------

.. rst-class:: build

**Least Connection**
  The server with the lowest number of connections receives the connection.
  Round-robin is performed within groups of servers of the same load to ensure
  that all servers will be used. Use of this algorithm is recommended where very
  long sessions are expected, such as LDAP, SQL, TSE, etc... but is not very
  well suited for protocols using short sessions such as HTTP.

**First Connection**
  The first server with available connection slots receives the connection. The
  servers are chosen from the lowest numeric identifier to the highest, which
  defaults to the server's position in the farm.  Once a server reaches its
  maxconn value, the next server is used.

Scheduling Algorithms
---------------------

.. rst-class:: build

**Source Connection**
  The source IP address is hashed and divided by the total weight of the running
  servers to designate which server will receive the request. This ensures that
  the same client IP address will always reach the same server as long as no
  server goes down or up.

**URI**
  This algorithm hashes either the left part of the URI (before the question
  mark) or the whole URI (if the "whole" parameter is present) and divides the
  hash value by the total weight of the running servers. The result designates
  which server will receive the request.  This ensures that the same URI will
  always be directed to the same server as long as no server goes up or down.

Common Load Balancer Features
-----------------------------

.. csv-table::
  :widths: 40, 90

  Asymmetric load, Ratio to be manually assigned to a backend server
  Priority Activation, "Add or remove backend servers based on the load or other
  metrics"
  SSL Offload & Acceleration, "Specialized hardware to offload SSL CPU demand on
  high traffic sites"
  DDoS attack protection, "Mitigate DDoS attacks using SYN cookies and verifying
  a full TCP handshake before sending off to the backend server"

Common Load Balancer Features
-----------------------------

.. csv-table::
  :widths: 40, 90

  HTTP compression, "Gzip compresses the HTTP objects to reduce bandwidth but
  can increase CPU usage"
  TCP offload, "Consolidate multiple HTTP requests from multiple clients into a
  single TCP socket to the backend servers"
  Health checking, "Balance pools the backend application server to see if its
  functioning correctly"
  HTTP caching, "Balancer stores the static content in memory to serve the
  content faster"

Persistence
-----------

* HTTP sessions
* Want to keep a connection with the same backend to maintain sessions
* Using memcached for storing sessions can help this
* *What other issues?*

Software Load Balancers
-----------------------

.. rst-class:: build

**HAProxy**
  High performance software based load balancer that uses TCP and can be used
  for multiple protocols. Been around since 2000 and used by Github, Reddit,
  Twitter, etc. Recently added SSL support but does no caching.

**Varnish**
  HTTP accelerator and static cache server. Focuses specifically on HTTP and can
  act as a load balancer similar to HAProxy. Used by Wikipedia, Facebook and
  Twitter to name a few.

Software Load Balancers
-----------------------

.. rst-class:: build

**Nginx**
  Webserver that can also act as a load balancer and a caching system. It
  generally has a low memory footprint.

**Apache**
  Webserver that can act as a load balancer via the ``mod_proxy`` module.
  Provides an easy way to set up but tends to use more memory than the others.

Proprietary Load Balancers
--------------------------

* BIG-IP (F5 Networks)
* NetScaler (Citrix)

Pros/Cons
---------

.. rst-class:: build

**Pros**
  * Helps you scale more easily
  * Gives you more flexibility on how to route your web traffic
  * Deal with backend outages more gracefully

**Cons**
  * Makes troubleshooting more complicated
  * Potential single point of failure
  * Configuration can be more complicated

*What else?*

HAProxy
=======

HAProxy Terminology
-------------------

**frontend**
    This defines how HAProxy should forward traffic to backends

**backend**
    A set of servers that receives traffic from HAProxy

**listen**
    A simpler version of frontend and backends

HAProxy Example Configuration
-----------------------------

::

    frontend http
      maxconn 2000
      bind 0.0.0.0:80
      default_backend servers

    frontend https
      maxconn 2000
      bind 0.0.0.0:443 ssl crt /etc/pki/tls/mycert.pem
      default_backend servers

    backend servers
      server mybackendserver 10.0.0.1:80
    # server <name> <ip>:<port> [options]

Check out the docs! http://www.haproxy.org/

HAProxy Example Configuration
-----------------------------

::

    frontend http
      maxconn 2000
      bind 0.0.0.0:80
      acl cs312 hdr(host) cs312.osuosl.org
      acl osl hdr(host) osuosl.org
      use_backend cs312_servers if cs312
      use_backend osl_servers if osl
      default_backend unrecognized_site

    backend cs312_servers
      server cs312-1 10.0.0.1:80
      server cs312-2 10.0.0.2:80

    backend osl_servers
      server osl-1 10.0.1.1:80
      server osl-2 10.0.1.2:80

    backend unrecognized_site
      server others 10.0.255.1:80

Hands-on HAProxy
----------------

1. Install and setup HAProxy
2. Setup several backends
3. Test failover with backends
4. Configure and test intranet page

Install HAProxy
---------------

Create a new VM

.. code-block:: console

  $ yum install haproxy
  $ systemctl start haproxy

Logging on HAProxy
------------------

HAProxy by default sends logs to localhost so we need to change the config to
send it directly to systemd.

Add the following to ``/etc/haproxy/haproxy.cfg``

::

  global
    log /dev/log local0 info

Global Config
-------------

::

  global
    log         /dev/log local0 info
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

Deploy some web applications
----------------------------

This script sets up a set of simple Python web servers that serve a simple web
page using systemd.

.. code-block:: console

  $ wget -O- http://cs312.osuosl.org/_static/hw/haproxy.sh | bash

Add Frontend/Backend
--------------------

Append the frontend and backend configuration to the ``haproxy.cfg`` file.

Try accessing the website using your VM's IP, what do you see?

::

  frontend http
    bind 0.0.0.0:80
    default_backend servers

  backend servers
    server www1 localhost:8003 check
    server www2 localhost:8004 check

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

.. code-block:: console

  $ systemctl stop cs312-www@8004

Changing the balancing algorithm
--------------------------------

.. code-block:: console
  :emphasize-lines: 2

  backend servers
    balance roundrobin
    server www1 localhost:8003 check
    server www2 localhost:8004 check

Adjusting the weighting
-----------------------

.. code-block:: console
  :emphasize-lines: 3-4

  backend servers
    balance roundrobin
    server www1 localhost:8003 weight 50 check
    server www2 localhost:8004 weight 100 check

Creating an ACL
---------------

ACLs enable you to direct traffic based on incoming traffic.

.. code-block:: console
  :emphasize-lines: 3-4

  frontend http
    bind 0.0.0.0:80
    acl url_www1 path_beg /www1
    acl url_www2 path_beg /www2
    default_backend servers

`HAProxy ACLs`_

.. _HAProxy ACLs: http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#7.1

Redirect traffic using an ACL
-----------------------------

Let's send traffic for the sub directory **/www1** to **www1** and **/www2** to
**www2**.

.. rst-class:: codeblock-sm

.. code-block:: console
  :emphasize-lines: 5-6,14-20

  frontend http
    bind 0.0.0.0:80
    acl url_www1 path_beg /www1
    acl url_www2 path_beg /www2
    use_backend www1 if url_www1
    use_backend www2 if url_www2
    default_backend servers

  backend servers
    balance roundrobin
    server www1 localhost:8003 weight 50 check
    server www2 localhost:8004 weight 100 check

  backend www1
    server www1 localhost:8003 weight 50 check

  backend www2
    server www2 localhost:8004 weight 50 check

Rewriting Headers
-----------------


.. rst-class:: codeblock-sm

.. code-block:: console
  :emphasize-lines: 4,8

  <snip>

  backend www1
    reqrep ^([^\ :]*)\ /www1[/]?(.*) \1\ /\2
    server www1 localhost:8003 weight 50 check

  backend www2
    reqrep ^([^\ :]*)\ /www2[/]?(.*) \1\ /\2
    server www2 localhost:8004 weight 50 check

Health Checks
-------------

Let's add a health check.

.. code-block:: console
  :emphasize-lines: 3

  backend servers
    balance roundrobin
    option httpchk GET /www1/
    server www1 localhost:8003 weight 50 check
    server www2 localhost:8004 weight 100 check

Also read up on ``http-check expect``.
