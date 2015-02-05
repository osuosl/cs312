.. _11_chef:


Chef Basics
===========

HW2 Kickstart explanation
-------------------------

*Why can I install httpd after the system is installed but not during
kickstart?*

* The kickstart/anaconda install environment doesn't include external repos by
  default.
* It can only install packages from the ISO image, which doesn't include httpd.
* The httpd package is included in the base repository for CentOS.
* Normally you want to add the Base and Updates repo in the kickstart.

Terminology
-----------

*Client*
    A client is identified by a key pair, used for authorization.

*Node*
    A machine you run ``chef-client`` on.

*Knife*
    A tool for interacting with the chef server.

*Berkshelf*
    A tool that manages cookbooks developed by others.


Terminology (cont)
------------------


*Foodcritic*
    A linting tool for chef.

`Rubocop`_
    A popular ruby linting tool, similar to pep8.

.. _Rubocop: https://github.com/bbatsov/rubocop

Even More Terminology
---------------------

*Test Kitchen*
    A framework for automatically bringing up machines, running chef, and then running tests.

*Serverspec*
    A testing framework for integration testing.


Ruby Syntax Primer
------------------

* Dynamic, strongly typed (*mostly* no implicit casting)
* Very implicit syntax

in Python

.. code-block:: python

    arr = [1,2,3]
    for x in arr:
        print(x)

in Ruby

.. code-block:: ruby

    arr = [1,2,3]
    arr.each do |x|
      puts x # look ma, no parentheses!
    end

Ruby Syntax Primer
------------------

Python

.. code-block:: python

    def sum(a,b):
        return a+b
    print(sum(3,5)) # prints "8"

Parentheses are not required in function calls in Ruby


.. code-block:: ruby

    def sum(a,b)
      return a+b
    end
    puts sum 3 5 # prints "8"


Ruby Syntax Primer
------------------

Python

.. code-block:: python

    def foo(x):
        return [ i+1 for i in x ]

Ruby

.. code-block:: ruby

    def implicit_foo(x)
      x.collect { |i| i+1 } # return is implicit
    end
    def explicit_foo(x)
      return x.collect { |i| i+1 }
    end

Ruby Syntax Primer
------------------

Python

.. code-block:: python

    arr = []
    if arr:
        print("the code never gets here")
    else:
        fill_arr(arr)

Ruby

.. code-block:: ruby

    arr = []
    if arr # this is the typecasting exception
        puts "Well, this is unexpected"
    else
        puts "The code never gets here!"
    end

Wait, What?
-----------

* Only ``nil`` and ``false`` tyepcast to a ``falsey`` value in Ruby

  - Unless you make a new class that is a descendant of ``NilClass`` or ``FalseClass``

* If you descend from ``Object`` (and not through ``FalseClass`` or ``NilClass``), you typecast to ``true``.

  - Gotchas: ``{}, [], '', "",``

    + Use ``.empty?``

.. code-block:: ruby

    arr = []
    if arr.empty?
      fill_arr arr
    else
      puts "the code never gets here"
    end

Syntactic Sugar
---------------

Ruby has a lot of syntactic sugar

.. code-block:: ruby

    var = "test"
    %w[a b #{var}] # same as ["a", "b", '#{var}']
    %W[a b #{var}] # same as ["a", "b", "test"]
    1 + 2 # sugar for 1.+(2)
    1.+(2) # sugar for 1.send(:+, 2)
    puts key1: 34, key2: 42 # outputs "{:key1 => 34, :key2 => 42}"


Procs
-----

In Ruby, a proc (procedure), is similar to a function in Python that has not been called, i.e

.. code-block:: python

    def bar():
        print("hello!")
    def foo(bar):
        bar()
    foo(bar) # prints "hello!"

in Ruby, this is:

.. code-block:: ruby

    bar = proc do
      puts "hello!"
    end
    def foo(bar)
      bar.call
    end
    foo bar # prints "hello!"

Blocks
------

A block is just an unnamed proc.

.. code-block:: ruby

    def foo(&block)
      block.call
    end

    foo do
      puts "hello!"
    end # prints "hello!"

The ``foo(&block)`` declaration tells ruby that this argument takes a block which will be passed in later, and to convert that block into a proc

Fake Chef
---------

You will notice chef syntax looks a lot like the last slide.

.. code-block:: ruby

    package "vim" do
      action :upgrade
    end

.. code-block:: ruby

    def action(ac)
      proc { |n| puts "apt-get #{ac} {n}"}
    end
    def package(n,&b) # n is just a regular old string
      b.call.curry[n]
    end
    package "vim" do
      action :upgrade
    end  # prints "apt-get ugprade vim"

In Chef ``action`` and other options are actually just symbols that get processed later.

One Last Thing
--------------

``do end`` and ``{}`` are equivalent. Use ``do end`` for multiline blocks, and ``{}`` for single lines:

.. code-block:: ruby

    [1,2,3].inject(0) { |s,i| s += i }
    {1:2, 3:4}.map do |k,v|
      puts "k+v is #{k+v}"
      puts "k*v is #{k*v}"
    end

Chef Components
---------------

* Cookbooks
* Nodes
* Roles
* Environments
* Data Bags

Cookbooks
---------

The major components are:

* Attributes
* Recipes
* Files/Templates
* Libraries/Definitions (helpers, we won't cover this)
* Lightweight Resource-Providers (we won't cover this)

Attributes
----------

Can be defined in any of the following:

* Cookbook
* Node
* Role
* Environment

There are 4 levels of attributes:

* Default
* Normal
* Override
* Automatic (special)

Attributes (Cookbook)
---------------------

* Found in the ``attributes/`` dir in the root of a cookbook.

.. code-block:: ruby

    default['my_cookbook']['package_i_want'] = 'vim'

* Often defined in recipes as well:

.. code-block:: ruby

    node.default['my_cookbook']['package_i_want'] = 'vim'

Attributes can be accessed in a recipe like the following

.. code-block:: ruby

    node['my_cookbook']['package_i_want']

Resources (Cookbook)
---------------------

* These are the workhorses of chef
* Most things that you can do are defined via resources. Chef has a syntax for resources

.. code-block:: ruby

    resource "name" do
      option "option_value"
    end

* Common resources used include: package, service, file, template,
* Universal options include ``action, subscribes, notifies, only_if, not_if``

Resource Examples
-----------------

.. code-block:: ruby

    package "apache2" do
      action :install
    end

    package "apache2" # the default action is :install

    service "apache2" do
      action [:start, :enable]
    end

    template "/etc/apache2/sites-available/mysite.conf" do
      source "mysite.conf.erb"
      owner "wwwdata"
      group "wwwdata"
      mode 0644 # like chmod (the 0 means octal in ruby)
      notifies :restart, "service[apache2]"
      variables :some_other_var => "example"
    end

Templates
---------

* Located in ``templates/``, usually in ``templates/default``. All template file names should end in ``.erb``
* ERB has two useful rules.

.. code-block:: erb

    <%= some_var %>
    <% puts some_var %>
    <%= @some_other_var %>

* The former just outputs the variable, the latter runs ruby.
* ``@some_other_var`` is a variable passed from the recipe

ERB Examples
------------

.. code-block:: erb

    <% some_var = [1,2] %>
    the next value is the first value in some_var:
    <%= some_var.first %>
    the next value is the sum of all values in some_var:
    <% puts some_var.inject(0){ |s,i| s += i } %>
    this is equivalent to the last value:
    <%= some_var.inject(0){ |s,i| s += i } %>

will render as

.. code-block:: none

    the next value is the first value in some_var:
    1
    the next value is the sum of all values in some_var:
    3
    this is equivalent to the last value:
    3

Files
-----

* Just like templates (but no ERB)
* Live in ``files/default/``
* Called with ``remote_file`` resource
* Should be avoided when possible

.. code-block:: ruby

    remote_file "/root/.bashrc" do
      owner "root"
      group "root"
      mode 0644
    end

Nodes
-----

* Node data
* Stored in JSON
* Can be written in ruby, but should not be.
* Should contain data specific to just the node.

.. code-block:: json

  {
    "name": "silk.osuosl.org",
    "chef_environment": "production",
    "run_list": [
      "role[racktables]",
      "role[jenkins_master]",
      "recipe[git]",
      "recipe[osl-slapd::client]"
    ],
  }


Roles
-----

* Node data that applies to >1 node
* Have their own attributes, run lists
* Per-environment run lists
* Added to a nodes ``run_list``
* JSON

.. code-block:: json

    {
      "env_run_lists": {},
      "run_list": [],
      "chef_type": "role",
      "default_attributes": {},
      "json_class": "Chef::Role",
      "description": "Role for all Drupal servers",
      "name": "project_drupal"
    }

Environments
------------

* Only have attributes
* Name accessed via ``node['chef_environment']``
* A node can only have one environment
* JSON

.. code-block:: json

    {
      "name": "dev",
      "description": "The development environment",
      "json_class": "Chef::Environment",
      "chef_type": "environment",
      "default_attributes": {
        "attr": "value"
      },
      "override_attributes": {}
    }

Data Bags
---------

* Data that doesn't fit in nodes, roles, or environments
* Can be encrypted
* JSON

.. code-block:: json

    {
      "id": "berkshelf-osuosl-bak",
      "interfaces": {
        "bak": {
          "device": "eth0",
          "bootproto": "static",
          "inet_addr": "10.1.1.31",
          "bcast": "10.1.1.255",
          "onboot": "yes"
        }
      }
    }

Test Kitchen
------------

* Helps make VMs, run chef, run tests
* Has plugin system for vagrant, openstack, virtualbox, etc
* Can use many test frameworks: rspec, serverspec, bats, chefspec
* Lots of magic
* Lives in ``.kitchen.yml``
* No reference documentation!

Kitchen YAML Example
--------------------

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

Kitchen Commands
----------------

These are the useful ones

* list
* create
* destroy
* converge
* verify
* setup
* test
* diagnose

Berksfile
---------

* Test-kitchen will automatically pull in cookbooks from Berksfile
* Secretly just ruby

.. code-block:: ruby

    source 'https://supermarket.chef.io'

    cookbook 'omnibus_updater'
    cookbook 'munin'
    cookbook 'runit', '1.5.10'

    metadata

Gemfile
-------

* Does double duty

    - ``bundle install`` to set up *host* development (we don't do this)
    - Test-kitchen installs the gems on the VM, required for pulling in test frameworks

.. code-block:: ruby

    source 'https://rubygems.org'

    # Strictly speaking, these three gems are unncessary
    gem 'berkshelf'
    gem 'test-kitchen'
    gem 'kitchen-vagrant'

    # this one installs our test framework
    gem 'serverspec'

Tests
-----

* Live in ``tests/integration/#{platform}/#{testframework}``
* We like serverspec.

.. code-block:: ruby

    require 'serverspec'


    set :background, :exec

    %w[haskell haskell-min].each do |p| # this is for laziness
      describe package(p) do # p is haskell or haskell-min
          it { should be_installed.with_version('1-4.0.el6') }
      end
    end
    describe file('/usr/bin/ghc') do
        it { should be_executable }
    end
