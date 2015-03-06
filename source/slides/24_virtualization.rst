.. _24_virtualization:

Virtualization
==============

IaaS/PaaS/SaaS, Ganeti, Cloud Images and Packer

<Name> as a Service
-------------------

**IaaS**
  Infrastructure as a Service
**Paas**
  Platform as a Service
**SaaS**
  Software as a Service

Infrastructure as a Service
---------------------------

*Virtual computing platform that typically includes automated methods for
deploying virtual machines on a set of physical machines*

Examples:

* EC2
* OpenStack
* oVirt
* Ganeti
* XenServer, VMWare ESX/ESXi
* Apache CloudStack, OpenNebula
* Microsoft Hyper-V

Platform as a Service
---------------------

*A platform that provides customers to develop, run and manage web applications
without the complexity of building and maintaining the underlying
infrastructure*

Typically layered on top of IaaS

Examples:

* AWS
* Salesforce
* Google App Engine
* Engine Yard
* Heroku
* OpenShift

Software as a Service
---------------------

*Software delivery model in which software is provided on a subscription basis
and centrally hosted. Also referred to as "on-demand software".*

* Typically layered on top of PaaS and/or IaaS
* Software is generally designed to be multi-tenant
* Updated by a central provider for all customers
* Provider deals with scaling up the application for customers

Examples:

* Google Docs, Twitter, Facebook, Flickr, etc
* Hosted Chef Server

Other IaaS Platforms
--------------------

.. csv-table::
  :widths: 30, 50

  Ganeti, "Virtual machine cluster management tool developed by Google"
  oVirt, "Virtualization platform and web interface developed by Red Hat"
  Apache CloudStack, "Cloud computing platform that interfaces with several
  HyperVisors"

Ganeti
------

**Key Features:**
  * High-availability built-in
  * Relatively simple architecture compared to other platforms
  * Easy to expand and manage
  * No cloud-like features by default -- good for "pet" VMs
  * Designed to deal with hardware failures
  * Does not use libvirt (was created before libvirt existed)
  * Primary CLI driven
  * Easy to customize

Ganeti Cluster
--------------

.. image:: ../_static/ganeti-cluster.png
  :width: 100%
  :align: center

Ganeti Components
-----------------

* Python
* Haskell
* DRBD
* LVM
* Hypervisor (KVM or Xen)

Distributed Replicated Block Device (DRBD)
------------------------------------------

**Distributed replicated storage system (think RAID1 over the network)**

.. image:: ../_static/drbd.png
  :width: 100%
  :align: center

KVM Live Migration
------------------

**A feature that allows a virtual machine to move from one host to another host
while staying online.**

* Depends on having a block device that is replicated on both nodes
* Transfers active memory
* Pauses VM
* Transfers state of vm to new host
* Continue VM

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration1.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration2.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration3.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration4.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration5.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

KVM Live Migration
------------------

.. figure:: ../_static/kvm-migration6.png
  :width: 100%
  :align: center

  http://www.linux-kvm.org/wiki/images/5/5a/KvmForum2007$Kvm_Live_Migration_Forum_2007.pdf

Ganeti Architecture
-------------------

.. image:: ../_static/ganeti-architecture.png
  :width: 100%
  :align: center

Ganeti Daemons
--------------

.. csv-table::

  ``ganeti-noded``, "Control hardware resources, runs on all nodes"
  ``ganeti-confd``,  "Only functional on master, runs on all nodes"
  ``ganeti-rapi``, "Offers HTTP-based API for cluster, runs on master"
  ``ganeti-masterd``, "Allows control of cluster, runs on master"

Ganeti Disk Templates
---------------------

**drbd**
  LVM + DRBD between 2 nodes
**plain**
  LVM with no redundancy
**file**
  Plain files, no redundancy

Primary and Secondary Nodes
---------------------------

.. image:: ../_static/primary-secondary.png
  :width: 100%
  :align: center

* Primary node is where the VM runs
* Secondary node is where its disk is replicated via DRBD. VM can be migrated
  over to it.

Cloud/System Image
------------------

*A copy of an operating system including the entire state of the computer system
stored in a non-volatile form such as a file.*

* A single file represents an entire filesystem
* Typically support extra features such as Copy-on-Write
* Snapshot support

Image Formats
-------------

**qcow/qcow2**
  * Used by QEMU/KVM
  * Stands for "QEMU Copy On Write"
**VHD (Virtual Hard Disk)**
  * Format created by Connectix which was later acquired by Microsoft
  * Used primarily by Hyper-V

Image Formats
-------------

**VMDK (Virtual Machine Disk)**
  * Initially developed by VMWare
  * An open format and used by VirtualBox, QEMU and Parellels
**AMI (Amazon Machine Image)**
  * Disk image format used on EC2
  * Compress, encrypted, signed and split into a series of 10MB checks and
    uploaded on S3
  * Contains an XML manifest file
  * Does not contain kernel image

Image files vs Block Devices
----------------------------

.. csv-table::
  :header: "Image Files", "Block Devices"

  "Easy to move around and create", "Requires use of LVM or other block device tools"
  "Can have a performance hit", "Typically has better performance"
  "Offer more features such as compression", "You can't 'overcommit' space with LVM"

Creating Images
---------------

*Various tools exist to create images. Some are distribution specific while
others aren't.*

**Oz**
  * Python CLI app that uses KVM to install a virtual machine image
  * Typically used to create RHEL-based images, but has support for Debian and
    Windows.
  * Uses an XML file format
**VMBuilder**
  * CLI tool that is typically used to create Debian or Ubuntu images

Creating Images
---------------

**BoxGrinder**
  * CLI tool that only works on Fedora but works on other RHEL systems
**VeeWee**
  * CLI tool to create Vagrant boxes, but can also create KVM images
**Packer**
  * CLI tool for creating machine images for multiple platforms
**imagefactory**
  * Tool that integrates with Oz to automate building, converting and uploading
    of images to different cloud providers.

Packer
------

* Machine image building tool created by Mitchell Hashimoto (of Vagrant fame)
* Written in Go

.. csv-table::

  Amazon EC2, Digital Ocean
  Docker, GCE
  Openstack, Parallels
  QEMU (kvm), Virtual Box
  VMWare

What problem does Packer solve?
-------------------------------

* One image building tool to rule them all
* Single configuration to create images across multiple platforms

  * Cloud? Vagrant? Docker? -- YES!

* Integrates into the cloud/devops model well

Terminology
-----------

**Templates**
  JSON files containing the build information
**Builders**
  Platform specific building configuration
**Provisioners**
  Tools that install software after the initial OS install
**Post-processors**
  Actions to happen after the image has been built

Packer Build Steps
------------------

*This varies depending on which builder you use. The following is an example for
the QEMU builder*

#. Download ISO image
#. Create virtual machine
#. Boot virtual machine from the CD
#. Using VNC, type in commands in the installer to start an automated install
   via kickstart/preseed/etc
#. Packer automatically serves kickstart/preseed file with a built-in http
   server

Packer Build Steps
------------------

6. Packer waits for ssh to become available
#. OS installer runs and then reboots
#. Packer connects via ssh to VM and runs provisioner (if set)
#. Packer Shuts down VM and then runs the post processor (if set)
#. PROFIT!

How it works
------------

.. rst-class:: codeblock-very-small

.. code-block:: json

  {
    "builders": [
      {
        "boot_command": [
          "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.0/ks-openstack.cfg",
          "<enter><wait>"
        ],
        "accelerator": "kvm",
        "boot_wait": "10s",
        "disk_size": 2048,
        "headless": true,
        "http_directory": "http",
        "iso_checksum": "df6dfdd25ebf443ca3375188d0b4b7f92f4153dc910b17bccc886bd54a7b7c86",
        "iso_checksum_type": "sha256",
        "iso_url": "{{user `mirror`}}/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-NetInstall.iso",
        "output_directory": "packer-centos-7.0-x86_64-openstack",
        "qemuargs": [ [ "-m", "1024m" ] ],
        "qemu_binary": "qemu-kvm",
        "shutdown_command": "echo 'centos'\|sudo -S /sbin/halt -h -p",
        "ssh_password": "centos",
        "ssh_port": 22,
        "ssh_username": "centos",
        "ssh_wait_timeout": "10000s",
        "type": "qemu",
        "vm_name": "packer-centos-7.0-x86_64"
    }],

How it works
------------

.. rst-class:: codeblock-very-small

.. code-block:: json

  {
    "provisioners": [
      {
        "environment_vars": [
          "CHEF_VERSION={{user `chef_version`}}"
        ],
        "execute_command": "echo 'centos' | {{.Vars}} sudo -S -E bash '{{.Path}}'",
        "scripts": [
          "scripts/centos/osuosl.sh",
          "scripts/centos/fix-slow-dns.sh",
          "scripts/common/sshd.sh",
          "scripts/common/vmtools.sh",
          "scripts/common/chef.sh",
          "scripts/centos/openstack.sh",
          "scripts/centos/cleanup.sh",
          "scripts/common/minimize.sh"
        ],
        "type": "shell"
      }
    ],
    "variables": {
      "chef_version": "provisionerless",
      "mirror": "http://centos.osuosl.org"
    }
  }

Building the Image
------------------

.. rst-class:: codeblock-sm

::

  $ packer build centos-7.0-x86_64-openstack.json
  qemu output will be in this color.

  ==> qemu: Downloading or copying ISO
      qemu: Downloading or copying: http://centos.osuosl.org/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-NetInstall.iso
  ==> qemu: Creating hard drive...
  ==> qemu: Starting HTTP server on port 8081
  ==> qemu: Found port for SSH: 3213.
  ==> qemu: Looking for available port between 5900 and 6000
  ==> qemu: Found available VNC port: 5947
  ==> qemu: Starting VM, booting from CD-ROM
      qemu: WARNING: The VM will be started in headless mode, as configured.
      qemu: In headless mode, errors during the boot sequence or OS setup
      qemu: won't be easily visible. Use at your own discretion.
  ==> qemu: Overriding defaults Qemu arguments with QemuArgs...
  ==> qemu: Waiting 10s for boot...
  ==> qemu: Connecting to VM via VNC
  ==> qemu: Typing the boot command over VNC...
  ==> qemu: Waiting for SSH to become available...

Provisioners
------------

.. csv-table::
  :widths: 30, 50

  Shell, Run either inline or shell scripts
  File Uploads, Upload files and use shell scripts to move files around as needed
  Ansible, Provision using playbook and role files
  Chef Client, Connect to a chef server and run chef
  Chef Solo, Run a Chef solo run by pointing to local cookbooks or uploading them
  Puppet Masterless, Run local manifests and modules
  Puppet Server, Connect to a puppet server and run puppet
  Salt, "Using Salt states, deploy a vm using Salt"
