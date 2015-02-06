.. _12_guest_and_midterm:

Geoffrey Corey
==============

Guest Speaker

Vagrant
-------

Vagranftiles are... *ok*

.. code-block:: ruby

    # Single box with default options.
    #
    Vagrant::Config.run do |config|
      config.vm.box = 'precise32'
      config.vm.box_url = 'http://files.vagrantup.com/precise32.box'
    end

`Complex`_ Vagrantfiles are not ok

.. _Complex: https://github.com/stackforge/openstack-chef-repo/blob/master/Vagrantfile-aio-neutron

Vagrant + Testing
-----------------

Testing and Vagrantfiles are not clear:

.. code-block:: ruby

    Vagrant.configure('2') do |config|
      config.vm.box = 'precise64'
      config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box'

      config.vm.provision :shell, inline: <<-EOF
        sudo ufw allow 22
        yes | sudo ufw enable
      EOF

      config.vm.provision :serverspec do |spec|
        spec.pattern = '*_spec.rb'
      end
    end

What is going on here?

Test-kitchen
------------

Test Kitchen is **MAGIC**! (until it is not...)

Test kitchen YAML files describe in a much clearer way what is going on.

Kitchen YAML Example
--------------------

(shamelessly plucked from Wednesday's slides)

.. code-block:: yaml

    ---
    driver:
      name: vagrant

    provisioner:
      name: chef_solo

    platforms:
      - name: ubuntu-12.04
      - name: centos-6.6

    suites:
      - name: default
        run_list:
          - apt::default
          - recipe[mycookbook]

When Test-kitchen is *NOT* Magic!
---------------------------------

.. code-block:: ruby

    >>>>>> Converge failed on instance <mysql-ubuntu14>.
    >>>>>> Please see .kitchen/logs/mysql-ubuntu14.log for more details
    >>>>>> ------Exception-------
    >>>>>> Class: Kitchen::ActionFailed
    >>>>>> Message: curve name mismatched (`*��ZlEC+�t6�R�M(m8������(' with `')
    >>>>>> ----------------------

Test-kitchen used cryptic error message. It's super effective!


Test-kitchen is *NOT* Magic! (cont)
-----------------------------------

**ALWAYS** blame ruby (or java, depending on context).

(Turns out it was a ruby ssh library and a newer key-type not yet supported)

Test Kitchen Plugins
--------------------

A lot of plugins exist for test kitchen:

* vagrant (duh!)
* openstack
* AWS
* Digital Ocean
* Chef
* Puppet

More comprehensive `list`_.

.. _list: http://misheska.com/blog/2014/09/21/survey-of-test-kitchen-providers/

Test Kitchen Plugins (cont)
---------------------------

* Docker (obligatory reference)

.. figure:: http://i.imgur.com/pAhrLmL.jpg
   :align: center

Midterm Notes
=============

Midterm Notes
-------------

Average: 67.9
Median: 66

Hard Questions (50% or fewer got these right)
---------------------------------------------

* What file typically contains user's hashed and salted passwords?
* Describe what ``yum`` and ``rpm`` are and what their primary differences are
* What does ``initrd`` stand for? What is its primary purpose?
* True/False: Git is a centralized version control system
* What does the special variable ``$$`` store?

Really Hard Questions (<= 25%)
------------------------------

* What type of file has the following permissions: ``crw-rw-rw-``?
* Name and describe three of the five components of LVM
* Describe what ``kickstart`` and ``anaconda`` are.

Really Hard Questions
---------------------

* Correctly order the following install steps for an automated install:

  * Download Linux Kernel/initrd image
  * Boot from network device (e.g PXE)
  * Using the kickstart file, install the system
  * Finish the install and reboot or shutdown the system
  * Get an IP address and information on where the boot server is
  * Grab the initial boot image


Really Hard Questions
---------------------

* Describe the following crontab interval: ``20 2 * * 3``
* What file could you look at to see the state of software raid on a Linux system?
* Who is Ken Thompson? Name at least two things he invented
* Is it possible for the ``df`` utility to report utilization over 100%? Explain
