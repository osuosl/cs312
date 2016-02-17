.. _ansible_demo:

Ansible Demo
============

Installation
------------

Install Ansible on ``flip.engr.oregonstate.edu``. Make sure your ssh key works
from flip.

.. code-block:: bash

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

  proj2 ansible_host=<ip address>  ansible_user=centos

Now ping the host using ansible::

  $ ansible all -i hosts -m ping
  proj2 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }

Create a playbook
-----------------

.. code-block:: yaml

  - hosts: proj2
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

.. code-block:: bash

  $ ansible-playbook -i hosts -s playbook.yml

  PLAY ***************************************************************************

  TASK [setup] *******************************************************************
  ok: [proj2]

  TASK [Install epel-release] ****************************************************
  changed: [proj2]

  TASK [Install packages] ********************************************************
  changed: [proj2] => (item=[u'ntp', u'htop'])

  TASK [Start ntp] ***************************************************************
  changed: [proj2]

  PLAY RECAP *********************************************************************
  proj2                      : ok=4    changed=3    unreachable=0    failed=0

* ``-s`` tells Ansible to use sudo

Inspect NTP service
-------------------

.. rst-class:: codeblock-sm

::

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

  - hosts: proj2
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

  - hosts: proj2
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

::

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

