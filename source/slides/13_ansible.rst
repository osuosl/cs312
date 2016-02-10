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
  Python-driven code that actually does the work in Ansible and executed on the
  remote host.
**Inventory**
  Defines how Ansible with interact with remote hosts and defines hosts, groups
  of hosts in a logical manner.
**Playbooks**
  Ansible's configuration, deployment and orchestration language that uses the
  YAML format.
**Roles**
  Reusable list of tasks and playbooks typically centered in a specific task.

Modules
-------

* Python code that is executed on the remote host
* Always returns JSON data
* Controls system resources, executing system commands
* Core Modules: Shipped and maintained by Ansible
* Extras Modules: Shipped with Ansible, but maintained by the community

Modules Categories
------------------

.. csv-table::

  Cloud, Clustering, Commands
  Database, Files, Inventory
  Messaging, Monitoring, Network
  Notification, Packaging, Source Control
  System, Utilities, Web Infra
  Windows

`Ansible Module Index`__

Module documentation::

  ansible-doc file

.. __: http://docs.ansible.com/ansible/modules_by_category.html

Files Module: copy
------------------

  *The [copy] module copies a file on the local box to remote locations. Use the
  [fetch] module to copy files from remote locations to the local box. If you
  need variable interpolation in copied files, use the [template] module.*

.. code-block:: yaml

  # Simple file copy
  - copy: src=/srv/myfiles/foo.conf
          dest=/etc/foo.conf
          owner=foo
          group=foo
          mode=0644

  # Copy a new "sudoers" file into place, after passing validation
  # with visudo
  - copy: src=/mine/sudoers
          dest=/etc/sudoers
          validate='visudo -cf %s'

Source Control Module: git
--------------------------

  *Manage 'git' checkouts of repositories to deploy files or software.*

.. code-block:: yaml

  - git: repo=git://foosball.example.org/path/to/repo.git
         dest=/srv/checkout
         version=release-0.22

Inventory
---------

* Contains all the hosts known to Ansible
* Also contains variables
* Can be flat files or dynamic via scripts
* Default location ``/etc/ansible/hosts``

::

  mail.example.com

  [webservers]
  foo.example.com
  bar.example.com

  [dbservers]
  one.example.com
  two.example.com
  three.example.com

Inventory communication variables
---------------------------------

.. csv-table::
  :header: Variable, Description
  :widths: 5, 10

  ``ansible_user``, The default ssh user name to use
  ``ansible_host``, "The name or IP of the host to connect to, if different from
  the alias you wish to give to it."
  ``ansible_port``, "The ssh port number, if not 22"

::

  wordpress-server ansible_host=140.211.168.106 ansible_user=centos

`List of other parameters`__

.. __: http://docs.ansible.com/ansible/intro_inventory.html#list-of-behavioral-inventory-parameters

Inventory Examples
------------------

Dynamic Inventory
-----------------

* Using external databases or APIs to manage your Ansible infrastructure
* Cloud provider, LDAP, Cobbler, or another CM Database

**Openstack Example**

::

  wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py
  chmod +x openstack.py
  ansible -i openstack.py all -m ping

See the `Ansible OpenStack Example`__ for more information.

.. __: http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-openstack-external-inventory-script

Ansible CLI
-----------

.. code-block:: bash

  # Usage: ansible host-pattern -m [module] \
  #   -a [module-options] [command-flags]

  # Ping all hosts with one line output
  ansible all -m ping -o
  # Run setup module gathering facts from the host
  ansible demo -m setup
  # Run an ad-hoc reboot command
  ansible foo.example.com -a “/usr/sbin/reboot”
  # Copy a file using the file module
  ansible demo -m file -a "dest=/srv/foo/a.txt mode=600" -o
  # Install httpd using the yum module
  ansible demo-one -m yum -a "name=httpd state=installed"
  # Start httpd using the service module
  ansible demo-one -m service -a "name=httpd state=started"

Playbooks
---------

* Expressed in YAML
* Usually composed of one or more "plays" in a list
* Allows for multi-machine deployment orchestration
* Lists tasks to execute
* Tasks are usually one module
* Include variables and handlers
* Idempotent

Playbook Example
----------------

.. rst-class:: codeblock-sm

.. code-block:: yaml

  - hosts: http
    remote_user: user
    sudo: yes
    vars:
     in_ports:
     - 80
     tasks:
     - name: install httpd
       action: yum name=httpd state=latest

     - name: copy httpd.conf
       action: template
          src=httpd.conf.j2
          dest=/etc/httpd/conf/httpd.conf
          owner=root
          group=root
          mode=0644
          seuser="system_u"
          setype="httpd_config_t"
          backup=yes
       notify:
       - restart httpd

Roles
-----

* Reusable list of tasks
* Usually has a single goal (i.e. deploy apache)
* Reusable

.. code-block:: yaml

  - hosts: demo
    gather_facts: False
    connection: local
    serial: 1
    vars:
     in_ports:
     - 80
    roles:
    - httpd
    - mysql
    - iptables

Templates
---------

* Jinas2 templating engine
* Use of variables
* Loops, conditionals, filters, etc

.. code-block:: jinja

  # Build an apache Proxy config
  < Proxy balancer://{{ balancer_name }}>
  {% for host in groups['demo-web'] %}
    BalancerMember http://{{ hostvars[host].ansible_eth1.ipv4.address }}
  {% endfor %}
    Order allow,deny
    Allow from all
  < /Proxy>

``ansible-playbook``
--------------------

* Execute a playbook
* Setting up a whole environment or set of hosts

::

  Usage: ansible-playbook playbook.yml -i inventory

Best Practices
--------------

.. code-block:: bash

  production      # inventory file for production servers
  stage           # inventory file for stage environment

  group_vars/
     group1       # here we assign variables to particular groups
     group2       # ""
  host_vars/
     hostname1    # if systems need specific variables, put them here
     hostname2    # ""

  site.yml        # master playbook
  webservers.yml  # playbook for webserver tier
  dbservers.yml   # playbook for dbserver tier

  roles/
      common/             # this hierarchy represents a "role"
          tasks/          #
              main.yml    #  <-- tasks file can include smaller files if warranted
          handlers/       #
              main.yml    #  <-- handlers file
          templates/      #  <-- files for use with the template
                          #      resource
              ntp.conf.j2 #  <------- templates end in .j2
          files/          #
              bar.txt     #  <-- files for use with the copy resource
              foo.sh      #  <-- script files for use with the script
                          #      resource
          vars/           #
              main.yml    #  <-- variables associated with this role

      webtier/            # same kind of structure as "common" was
                          # above, done for the webtier role
      monitoring/         # ""
      fooapp/             # ""

Patterns
--------

Ansible Config File
-------------------

Variables
---------

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

* `Ansible: an introduction (Jan-Pet Mens)`__
* `Ansible - introduction (Stephane Manciot)`__
* `Introduction to Ansible (Mattias Gees)`__

.. __: https://speakerdeck.com/jpmens/ansible-an-introduction
.. __: http://www.slideshare.net/StephaneManciot/ansible-44734246
.. __: http://blog.mattiasgees.be/presentations/ansible_introduction/
