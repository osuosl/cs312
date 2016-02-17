.. _ansible_demo:

Ansible Demo
============

Installation
------------

Install Ansible on ``flip.engr.oregonstate.edu``. Make sure your ssh key works
from flip.

.. code-block:: console

  bash
  mkdir ansible
  cd ansible/
  virtualenv-2.7 venv
  source venv/bin/activate
  pip install ansible
  ansible -h

* `virtualenv`__ is a tool to create isolated Python environments
* Must always activate the environment by sourcing ``venv/bin/activate``
* Ansible requires at least Python 2.7 on the control node

.. __: https://virtualenv.readthedocs.org/en/latest/

Setup the Inventory
-------------------

* Spin up a new VM on OpenStack
* Setup an inventory file called ``hosts``

.. code-block:: bash

  [cs312]
  cs312 ansible_ssh_host=<ip address> ansible_ssh_user=centos

Now ping the host using ansible:

.. code-block:: console

  $ ansible all -i hosts -m ping
  cs312 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }

Create a playbook
-----------------

.. code-block:: yaml

  - hosts: cs312
    tasks:
      - name: Install epel-release
        yum: name=epel-release state=present

      - name: Install packages
        yum: name={{ item }} state=present
        with_items:
        - ntp
        - htop

      - name: Start ntp
        service: name=ntpd state=started enabled=yes

Run playbook
------------

.. rst-class:: codeblock-sm

.. code-block:: console

  $ ansible-playbook -i hosts -s playbook1.yml

  PLAY ***************************************************************************

  TASK [setup] *******************************************************************
  ok: [cs312]

  TASK [Install epel-release] ****************************************************
  changed: [cs312]

  TASK [Install packages] ********************************************************
  changed: [cs312] => (item=[u'ntp', u'htop'])

  TASK [Start ntp] ***************************************************************
  changed: [cs312]

  PLAY RECAP *********************************************************************
  cs312                      : ok=4    changed=3    unreachable=0    failed=0

``-s`` tells Ansible to use sudo

Inspect NTP service
-------------------

.. rst-class:: codeblock-sm

.. code-block:: console

  $ systemctl status ntpd
  ● ntpd.service - Network Time Service
     Loaded: loaded (/usr/lib/systemd/system/ntpd.service; enabled; vendor
  preset: disabled)
     Active: active (running) since Wed 2016-02-17 16:09:00 UTC; 4min 52s ago
    Process: 3392 ExecStart=/usr/sbin/ntpd -u ntp:ntp $OPTIONS (code=exited,
  status=0/SUCCESS)
   Main PID: 3393 (ntpd)
     CGroup: /system.slice/ntpd.service
             └─3393 /usr/sbin/ntpd -u ntp:ntp -g


  $ systemctl list-unit-files ntpd.service
  UNIT FILE    STATE
  ntpd.service enabled

Ansible Template
----------------

Create this as ``ntp.conf.j2``

.. code-block:: jinja

  # {{ ansible_managed }}

  # Default settings from CentOS
  driftfile /var/lib/ntp/drift
  restrict default nomodify notrap nopeer noquery
  restrict 127.0.0.1
  restrict ::1
  includefile /etc/ntp/crypto/pw
  keys /etc/ntp/keys
  disable monitor

  # NTP servers
  {% for item in ntp_servers %}
  server {{ item }}
  {% endfor %}

Add template task and variables
-------------------------------

.. code-block:: yaml
  :emphasize-lines: 2-5,16-17

  - hosts: cs312
    vars:
      ntp_servers:
      - pool.ntp.org
      - time.oregonstate.edu
    tasks:
      - name: Install epel-release
        yum: name=epel-release state=present

      - name: Install packages
        yum: name={{ item }} state=present
        with_items:
        - ntp
        - htop

      - name: ntp.conf
        template: src=ntp.conf.j2 dest=/etc/ntp.conf

      - name: Start ntp
        service: name=ntpd state=started enabled=yes

Setup Handlers
--------------

.. code-block:: yaml
  :emphasize-lines: 18-19, 24-26

  - hosts: cs312
    vars:
      ntp_servers:
      - pool.ntp.org
      - time.oregonstate.edu
    tasks:
      - name: Install epel-release
        yum: name=epel-release state=present

      - name: Install packages
        yum: name={{ item }} state=present
        with_items:
        - ntp
        - htop

      - name: ntp.conf
        template: src=ntp.conf.j2 dest=/etc/ntp.conf
        notify:
        - restart ntpd

      - name: Start ntp
        service: name=ntpd state=started enabled=yes

    handlers:
      - name: restart ntpd
        service: name=ntpd state=restarted

Creating a role
---------------

.. code-block:: console

  $ ansible-galaxy init roles/ntp
  - roles/ntp was created successfully
  $ find roles/ntp/
  roles/ntp/
  roles/ntp/README.md
  roles/ntp/.travis.yml
  roles/ntp/defaults
  roles/ntp/defaults/main.yml
  roles/ntp/files
  roles/ntp/handlers
  roles/ntp/handlers/main.yml
  roles/ntp/meta
  roles/ntp/meta/main.yml
  roles/ntp/tasks
  roles/ntp/tasks/main.yml
  roles/ntp/templates
  roles/ntp/vars
  roles/ntp/vars/main.yml
  roles/ntp/tests
  roles/ntp/tests/test.yml
  roles/ntp/tests/inventory

Roles: Tasks, Handlers, Templates
---------------------------------

.. code-block:: yaml
  :caption: roles/ntp/tasks/main.yml

  - name: Install NTP
    yum: name=ntp state=present

  - name: ntp.conf
    template: src=ntp.conf.j2 dest=/etc/ntp.conf
    notify:
    - restart ntpd

.. code-block:: yaml
  :caption: roles/ntp/handlers/main.yml

  - name: restart ntpd
    service: name=ntpd state=restarted

Template copied to ``roles/ntp/templates/ntp.conf.j2``

Set Roles Path
--------------

Create an ``ansible.cfg`` file at the root of your ansible repo with this::

  [defaults]
  inventory=hosts
  roles_path=roles

Run the role
------------

.. code-block:: yaml

  - hosts: cs312
    vars:
      ntp_servers:
      - pool.ntp.org
      - time.oregonstate.edu
    roles:
      - ntp
    tasks:
      - name: Install epel-release
        yum: name=epel-release state=present

      - name: Install packages
        yum: name={{ item }} state=present
        with_items:
        - htop

::

  ansible-playbook -s site.yml

Roles from Ansible Galaxy
-------------------------

.. code-block:: console

  $ ansible-galaxy install bennojoy.ntp
  - downloading role 'ntp', owned by bennojoy
  - downloading role from https://github.com/bennojoy/ntp/archive/master.tar.gz
  - extracting bennojoy.ntp to roles/bennojoy.ntp
  - bennojoy.ntp was installed successfully

.. code-block:: yaml
  :emphasize-lines: 2

    roles:
      - bennojoy.ntp

::

  ansible-playbook -s site.yml

Integration Testing with ServerSpec
-----------------------------------

* `AnsibleSpec`__ is a Ruby gem that implements an Ansible Config Parser for
  Serverspec
* Creates a Rake task that can run tests, using Ansible inventory files and
  playbooks
* You can test multiple roles and multiple hosts
* `ServerSpec`__ is RSpec tests for servers

::

  gem install ansible_spec

AnsibleSpec Setup
-----------------

.. code-block:: yaml
  :emphasize-lines: 2,8

  - hosts: cs312
    name: NtpTests
    vars:
      ntp_servers:
      - pool.ntp.org
      - time.oregonstate.edu
    roles:
      - ntp
    tasks:
      - name: Install epel-release
        yum: name=epel-release state=present

      - name: Install packages
        yum: name={{ item }} state=present
        with_items:
        - htop



ServerSpec on Ansible
---------------------

.. code-block:: console

  $ ansiblespec-init
      create  spec
      create  spec/spec_helper.rb
      create  Rakefile
      create  .ansiblespec

``roles/ntp/spec/ntp_spec.rb``

.. code-block:: ruby

  require 'spec_helper'

  describe package('ntp') do
    it { should be_installed }
  end

  describe service('ntpd') do
    it { should be_running }
    it { should be_enabled }
  end

.. __: https://github.com/volanja/ansible_spec
.. __: http://serverspec.org/

Run the tests
-------------

.. code-block:: console

  $ rake -T
  rake serverspec:NtpTests  # Run serverspec for NtpTests

  $ rake serverspec:NtpTests
  Run serverspec for NtpTests to {"name"=>"cs312
  ansible_ssh_host=140.211.168.106 ansible_ssh_user=centos",
  "port"=>22, "uri"=>"140.211.168.106", "user"=>"centos"}
  /opt/chefdk/embedded/bin/ruby
  -I/opt/chefdk/embedded/lib/ruby/gems/2.1.0/gems/rspec-support-3.3.0/lib:/opt/chefdk/embedded/lib/ruby/gems/2.1.0/gems/rspec-core-3.3.2/lib
  /opt/chefdk/embedded/lib/ruby/gems/2.1.0/gems/rspec-core-3.3.2/exe/rspec
  --pattern roles/\{ntp\}/spec/\*_spec.rb
  ...

  Finished in 0.86835 seconds (files took 0.68036 seconds to load)
  3 examples, 0 failures

Class Exercise
--------------

Construct a role that passes this ServerSpec File:

::

  require 'spec_helper'

  %w(vim-enhanced curl wget git bind-utils).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe('emacs') do
    it { should_not be_installed }
  end

  describe file('/root/.bashrc/) do
    it { should be_file }
    its(:content){ should match /export EDITOR=vim/ }
  end

  describe file('/root/mysupermostfavoritedirectory') do
    it { should be_directory }
  end
