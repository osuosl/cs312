.. _14_chefdk_tk:

ChefDK and Test Kitchen Hands-on
================================

Summary for today
-----------------

* Deploy a test cookbook using Test Kitchen
* Do some basic linting fixes
* Add some simple features
* Talk about community cookbooks

Test Kitchen on Openstack
-------------------------

* Typically name this ``.kitchen.cloud.yml``

.. rst-class:: codeblock-sm

.. code-block:: yaml

  ---
  driver_config:
    openstack_username: <%= ENV['OS_USERNAME'] %>
    openstack_api_key: <%= ENV['OS_PASSWORD'] %>
    openstack_auth_url: <%= "#{ENV['OS_AUTH_URL']}/tokens" %>
    key_name: <%= ENV['OS_SSH_KEYPAIR'] %>
    private_key_path: <%= ENV['OS_PRIVATE_SSH_KEY'] %>
    public_key_path: <%= ENV['OS_PUBLIC_SSH_KEY'] %>
    openstack_tenant: <%= ENV['OS_TENANT_NAME'] %>
    floating_ip: <%= ENV['OS_FLOATING_IP'] %>
    floating_ip_pool: <%= ENV['OS_FLOATING_IP_POOL'] %>
    flavor_ref: <%= ENV['OS_FLAVOR_REF'] %>

  provisioner:
    name: chef_solo
    attributes:
      authorization:
        sudo:
          users:
            - centos
          passwordless: true

Test Kitchen on Openstack
-------------------------

*Continued...*

.. rst-class:: codeblock-sm

.. code-block:: yaml

  platforms:
  - name: centos-6.6
    driver_plugin: openstack
    driver_config:
      username: centos
      image_ref: "CentOS 6.6"

    suites:
      - name: default
        run_list:
          - recipe[osl-testcookbook::default]
      - name: wiki
        run_list:
          - recipe[osl-testcookbook::wiki]
      - name: style
        run_list:
          - recipe[osl-testcookbook::style]

Test Kitchen commands
---------------------

.. code-block:: bash

  $ kitchen list # only works if you have vagrant installed
  Instance           Driver   Provisioner  Last Action
  default-centos-66  Vagrant  ChefSolo     <Not Created>
  wiki-centos-66     Vagrant  ChefSolo     <Not Created>

  $ kitchen test default # Converge VM, run tests and destroy
  $ kitchen conv default # Converge VM (useful for development)
  $ kitchen verify default # Run tests but don't destroy
  $ kitchen login default # ssh into the VM

  # Run Openstack config
  $ KITCHEN_YAML=.kitchen.cloud.yml kitchen test default

  # Add this to your .bashrc as a useful alias
  alias tkc="KITCHEN_YAML=.kitchen.cloud.yml kitchen $@"

  # Run using your new alias (don't forget to source .bashrc!)
  $ tkc test default

Test Kitchen commands
---------------------

.. rst-class:: codeblock-sm

.. code-block:: bash

  $ kitchen
  Commands:
    kitchen console                         # Kitchen Console!
    kitchen converge [INSTANCE|REGEXP|all]  # Converge one or more instances
    kitchen create [INSTANCE|REGEXP|all]    # Create one or more instances
    kitchen destroy [INSTANCE|REGEXP|all]   # Destroy one or more instances
    kitchen diagnose [INSTANCE|REGEXP|all]  # Show computed diagnostic configuration
    kitchen driver                          # Driver subcommands
    kitchen driver create [NAME]            # Create a new Kitchen Driver gem project
    kitchen driver discover                 # Discover Test Kitchen drivers published on
                                            # RubyGems
    kitchen driver help [COMMAND]           # Describe subcommands or one specific
                                            # subcommand
    kitchen help [COMMAND]                  # Describe available commands or one specific
                                            # command
    kitchen init                            # Adds some configuration to your cookbook so
                                            # Kitchen can rock
    kitchen list [INSTANCE|REGEXP|all]      # Lists one or more instances
    kitchen login INSTANCE|REGEXP           # Log in to one instance
    kitchen setup [INSTANCE|REGEXP|all]     # Setup one or more instances
    kitchen test [INSTANCE|REGEXP|all]      # Test one or more instances
    kitchen verify [INSTANCE|REGEXP|all]    # Verify one or more instances
    kitchen version                         # Print Kitchen's version information

Openstack Env Variables
-----------------------

* Example: user: ``albertsl`` tenant: ``albertsl-cs312``
* Add this to your ``~/.bashrc`` file then run ``source ~/.bashrc``

.. rst-class:: codeblock-sm

.. code-block:: bash

  # OpenStack Variables
  export OS_USERNAME=albertsl
  export OS_PASSWORD=<your openstack password>
  export OS_TENANT_NAME=albertsl-cs312
  export OS_AUTH_URL=http://studentcloud.osuosl.org:5000/v2.0/
  export OS_PUBLIC_SSH_KEY=<openstack ssh public key full path location>
  export OS_PRIVATE_SSH_KEY=<openstack ssh private key full path location>
  # This should be called whatever you just imported
  export OS_SSH_KEYPAIR=<ssh keypair name>
  export OS_FLAVOR_REF=cs312

Serverspec
----------

`ServerSpec Resource Types`_

.. code-block:: ruby

  require 'serverspec'

  set :background, :exec

  %(vim-enhanced curl wget git bind-utils emacs).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe package('emacs') do
    it { should_not be_installed }
  end

.. _ServerSpec Resource Types: http://serverspec.org/resource_types.html

Tasks
-----

1. Create a branch ``$onid/cs312`` for your work
2. Fix the ``default`` recipe so it passes all the tests written for it
3. Write the missing tests for the ``wiki`` recipe
4. Fix all foodcritic issues
5. Fix all rubocop issues

Fix default recipe
------------------

Make sure it matches the tests written for it

* emacs should not be installed
* ``/root/.bashrc`` should have some specific content
* Should have a directory at ``/root/mysupermostfavoritedirectory``

Solution
--------

File in ``files/default/bashrc`` with content we need.

.. code-block:: ruby

  package 'emacs' do
    action :remove
  end

  cookbook_file '/root/.bashrc' do
    owner 'root'
    group 'root'
    source 'bashrc'
    action :create
  end

  directory '/root/mysupermostfavoritedirectory' do
    owner 'root'
    group 'root'
    action :create
  end

Tests for wiki recipe
---------------------

1. nginx package, service
2. Existence of webroot and index.html
3. What else?

Solution
--------

.. rst-class:: codeblock-sm

.. code-block:: ruby

  require 'serverspec'

  set :backend, :exec

  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/var/www/wiki.osuosl.org') do
    it { should be_directory }
  end

  describe file('/var/www/wiki.osuosl.org/build/html/index.html') do
    it { should be_file }
  end

Fix foodcritic issues
---------------------

1. Two in ``metadata.rb``
2. The rest in the ``style`` recipe

Fix rubocop issues
------------------

1. All files under recipes

Wednesday
---------

* Bring laptops again!
* More on Chef cookbooks
* Homework assigned tomorrow (We'll email the list)
