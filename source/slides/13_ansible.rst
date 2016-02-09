.. _13_ansible:

Ansible
=======

What is Ansible?
----------------

* Started in 2012
* More than 600 contributors
* Orchestration Engine

  * Configuration Management
  * Application Deployment
  * Continuous Delivery

Ansible Commands
----------------

``ansible``
  Low level command to execute simple Ansible resources
``ansible-playbook``
  Tool to run Ansible Playbooks
``ansible-pull``
  Tool to pull remote Ansible configurations and run the playbooks
``ansible-doc``
  Tool to show documentation on Ansible modules
``ansible-galaxy``
  Tool to manage roles from Ansible Galaxy, a shared repository of Ansible roles
  maintained by the community

Ansible Components
------------------

**Modules**
**Inventory**
**Playbooks**
**Roles**
**Templates**

Inventory
---------

Dynamic Inventory
-----------------

Patterns
--------

Ad-hoc commands
---------------

Ansible Config File
-------------------

Playbooks
---------

Roles
-----

Variables
---------

Modules
-------

Hands-on
========

Installing Ansible
------------------

.. code-block:: bash

  # EPEL repo
  yum install ansible

  # Available through a PPA
  apt-get install ansible

  # Also available via pip
  pip install ansible

Resources
---------

.. __: https://speakerdeck.com/jpmens/ansible-an-introduction
.. __: http://www.slideshare.net/StephaneManciot/ansible-44734246
.. __: http://blog.mattiasgees.be/presentations/ansible_introduction/
