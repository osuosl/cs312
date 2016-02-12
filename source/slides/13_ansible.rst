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

.. rst-class:: build

``ansible``
  Low level command to execute simple Ansible resources
``ansible-playbook``
  Tool to run Ansible Playbooks
``ansible-pull``
  Tool to pull remote Ansible configurations and run the playbooks locally
``ansible-doc``
  Tool to show documentation on Ansible modules
``ansible-galaxy``
  Tool to manage roles from Ansible Galaxy, a shared repository of Ansible roles
  maintained by the community

Ansible Components
------------------

.. rst-class:: build

**Modules**
  Python-driven code that actually does the work in Ansible and executed on the
  remote host.
**Inventory**
  Defines how Ansible with interact with remote hosts and defines hosts, groups
  of hosts in a logical manner. You also define host and group variables inside
  the inventory.
**Playbooks**
  Ansible's configuration, deployment and orchestration language that uses the
  YAML format.
**Roles**
  Reusable list of tasks and playbooks typically centered in a specific task,
  such as deploying a web service

Modules
-------

* Python code that is executed on the remote host
* Always returns JSON data
* Controls and manage system resources
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

Facts
-----

* `Facts`__ is a core module that gathers useful variables about remote hosts
* All Ansible facts are prefixed with ``ansible_``
* If factor (Puppet) or ohai (Chef) is installed, Ansible will gather those
  folks too and prefix them respectively

.. rst-class:: codeblock-sm

.. code-block:: bash

  # Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
  ansible all -m setup --tree /tmp/facts

  # Display only facts regarding memory found by ansible on all hosts and output them.
  ansible all -m setup -a 'filter=ansible_*_mb'

  # Display only facts returned by facter.
  ansible all -m setup -a 'filter=facter_*'

  # Display only facts about certain interfaces.
  ansible all -m setup -a 'filter=ansible_eth[0-2]'

.. __: https://docs.ansible.com/ansible/setup_module.html

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

.. code-block:: bash

  # Range of hosts using patterns
  [webservers]
  www[01:50].example.com

  # Host variables
  [atlanta]
  host1 http_port=80 maxRequestsPerChild=808
  host2 http_port=303 maxRequestsPerChild=909

  # Group Variables
  [atlanta]
  host1
  host2

  [atlanta:vars]
  ntp_server=ntp.atlanta.example.com
  proxy=proxy.atlanta.example.com

Groups of groups, and group variables
-------------------------------------

Using the ``:children`` suffix allows for groups of groups.

::

  [atlanta]
  host1
  host2

  [raleigh]
  host2
  host3

  [southeast:children]
  atlanta
  raleigh

  [southeast:vars]
  some_server=foo.southeast.example.com
  halon_system_timeout=30
  self_destruct_countdown=60
  escape_pods=2

  [usa:children]
  southeast
  northeast
  southwest
  northwest

Patterns
--------

`Patterns`__ in Ansible decide which hosts to manage

* All hosts in the inventory: ``all`` or ``*``
* Specific host or group: ``host1``, ``webservers``
* Wildcard: ``192.168.1.*``
* OR: ``host1:host2``, ``webservers:dbservers``
* NOT: ``webservers:dbservers:!production``
* AND: ``webservers:dbservers:&staging``
* REGEX: ``~(web|db).*\.example\.com``

.. __: http://docs.ansible.com/ansible/intro_patterns.html

Pattern Examples
----------------

.. code-block:: bash

  # Run this on the webservers group
  ansible webservers -m service -a "name=httpd state=restarted"

  # Target all hosts
  all
  *

  # Target specific host or a set of hosts
  one.example.com
  one.example.com:two.example.com
  192.168.1.50
  192.168.1.*

  # Target groups or one or more groups. Colon indicates OR
  webservers
  webservers:dbservers

  # Exclude groups
  webservers:!phoenix

  # Intersection of two groups. Hosts would need to be in both groups
  # to run.
  webservers:&staging

  # Combo!
  # All machines in the groups ‘webservers’ and ‘dbservers’ are to be
  # managed if they are in the group ‘staging’ also, but the machines
  # are not to be managed if they are in the group ‘phoenix
  webservers:dbservers:&staging:!phoenix

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

Handlers
--------

* Basic event system that can be triggered from tasks
* Events can only be triggered once
* Handlers usually be used to restart services

.. code-block:: yaml

  - name: template configuration file
    template: src=template.j2 dest=/etc/foo.conf
    notify:
       - restart memcached
       - restart apache

  # Handlers
  - name: restart memcached
    service: name=memcached state=restarted
  - name: restart apache
    service: name=apache state=restarted

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

* `Jinja2 templating engine`__
* Use of variables
* Loops, conditionals, filters, etc

.. __: http://jinja.pocoo.org/

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

Variables
---------

* `Variables`__ allow you to deal with differences between systems
* Valid names should be letters, numbers, and underscores and always start with
  a letter

.. rst-class:: codeblock-sm

.. code-block:: yaml
  :caption: playbook.yml

  - hosts: webservers
    template: src=foo.cfg.j2 dest={{ remote_install_path }}/foo.cfg
    vars:
      http_port: 80

.. code-block:: jinja
  :caption: Templates

  My amp goes to {{ max_amp_value }}

.. __: http://docs.ansible.com/ansible/playbooks_variables.html

YAML Gotchas
------------

Sometimes YAML is quirky so read up on the `YAML Syntax`__

For example, this won't work:

.. code-block:: yaml

  - hosts: app_servers
    vars:
        app_path: {{ base_path }}/22

However this will work fine:

.. code-block:: yaml

  - hosts: app_servers
    vars:
         app_path: "{{ base_path }}/22"

.. __: http://docs.ansible.com/ansible/YAMLSyntax.html

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

* `Ansible Examples repo`__
* `Ansible: an introduction (Jan-Pet Mens)`__
* `Ansible - introduction (Stephane Manciot)`__
* `Introduction to Ansible (Mattias Gees)`__

.. __: https://github.com/ansible/ansible-examples
.. __: https://speakerdeck.com/jpmens/ansible-an-introduction
.. __: http://www.slideshare.net/StephaneManciot/ansible-44734246
.. __: http://blog.mattiasgees.be/presentations/ansible_introduction/
