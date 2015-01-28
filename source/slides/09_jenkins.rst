.. _09_jenkins:

Jenkins
=======

Announcements
-------------

* HW#2 is assigned (Due next Wednesday)
* Midterm on Friday

Objectives today
----------------

* Install Jenkins and set it up
* Fork and clone a repository from github
* Create jobs that are triggered from github
* Add Travis-ci checks

Installing Jenkins
------------------

http://pkg.jenkins-ci.org/redhat/

.. code-block:: bash

  # Add yum repo file
  $ wget -O /etc/yum.repos.d/jenkins.repo \
      http://pkg.jenkins-ci.org/redhat/jenkins.repo

  # Add repo gpg key
  $ rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

  # Install jenkins from repo
  $ yum install jenkins java-1.6.0-openjdk

  # Start jenkins
  $ service jenkins start

Securing Jenkins
----------------

* By default jenkins has no logins!
* Click on:

  * Manage Jenkins -> Setup Security
  * Enable Security
  * (Access Control) -> Jenkins’ own user database -> Uncheck signup
  * Logged-in users can do anything
  * User sign up

Installing plugins
------------------

* Install Github plugin

Fork repo
---------

* Fork this repo: https://github.com/osuosl/cs312-demo

Create a jenkins job
--------------------

What we'll do today:

* Clone the repo
* Run a script
* Manually run job

Steps to add job
----------------

#. Click **create new jobs**
#. Choose **Freestyle project** and name it ``cs312-demo``
#. Add your fork's URL to **Github project**
#. Click **Git** and add URL
#. Check **Build when a change is pushed to GitHub** under **Build Triggers**
#. Click **Save**
#. Click **Build Now**

*Does it work? Check the output!*

Github Hooks
------------

#. Go to your fork and click on **Settings**
#. Click on **Webhooks & Services**
#. Click on **Add service**, search for **Jenkins (GitHub plugin)**
#. Using your public IP, set the hook URL: i.e.
   ``http://140.211.168.XXX:8080/github-webhook/``
#. Click **Add Service**
#. Click the jenkins service
#. Click **Test Service**
#. Back on jenkins, click on **Github Hook Log**

Add tests!
----------

Make a branch and add the following ``.travis.yml`` config:

.. code-block:: yaml

  language: ruby
  sudo: false
  cache: bundler
  rvm:
    - 2.2
  install:
    - bundle install --retry=3
  script:
    - bundle exec rubocop


Travis CI Setup
---------------

#. Goto https://travis-ci.org and login
#. Search for ``cs312-demo`` (you might need to force a sync)
#. Click enable and **Build only if .travis.yml is present**

Pull request
------------

* Make a pull request (on your own repo) with the fix
* Work? Yay! Merge!
