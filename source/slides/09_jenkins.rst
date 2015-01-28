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

* Fork this repo: TODO

Create a jenkins job
--------------------

* Clone the repo
* Run a script
* Manually run job

Github Hooks
------------

* Integrate with Jenkins
* Test job: Commit to the repo and push

Travis CI Setup
---------------

* <Instructions here>

Add tests!
----------

* Do rubocop setup
* It breaks!

Pull request
------------

* Make a pull request (on your own repo) with the fix
* Work? Yay! Merge!
