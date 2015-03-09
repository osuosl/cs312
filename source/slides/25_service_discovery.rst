.. _25_service_discovery:

Distributed Systems
===================

Definition
----------

Distributed systems are systems which are connected by a network,
and use some form of message passing to communicate and compute correctly.

Usefulness
----------

* Redundancy
* Fault-tolerance
* Horizontal Scalability & Parallelization

Problems
--------

What are some problems that can occur?

Two Generals Problem
--------------------

Suppose you are one of two generals who are attempting to coordinate
an attack on an enemy at a particular time.

You can freely send as many messages as you like, although they have no
guarantee of arrival.

How can you guarantee that you and the other general attack at the same time?

Byzantine Fault
---------------

A Byzantine Fault is any problem in which two different observers observe
different symptoms.

Examples?

Example
-------

Suppose you run nagios using passive checks, but unfortunately you observe
that the networking out of your datacenter has issues from time to time.

You have no control over these issues.

Now suppose you set up a second nagios server in another datacenter, and all
machines send check results to both nagios servers. What situations can occur?

Example
-------

Both Nagios servers will send agreeing alerts when something is down.
Each Nagios server will send different alerts (or no alerts) when a
Byzantine Fault occurs.

Service Discovery
=================

Automated & Distributed Systems
-------------------------------

* Systems turn from pets to cattle
* We no longer really care which systems are up, we just want
  at least ``$X`` of them running at a time
* Why care at all where or how they run?

  * They still have to find each other!

Service Discovery
-----------------

DHCP is a form of specialized service discovery. Why?

Service Discovery
-----------------

etcd, zookeeper, consul

* Typically arbitrary key-value stores (but *not* databases)

  * Why not nosql?

* Abstract the bootstrapping problem to just the service-discovery cluster
* CoreOS attempts to solve bootstrapping with `etcd discovery`_

.. _etcd discovery: https://discovery.etcd.io/
