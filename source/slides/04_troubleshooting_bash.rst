.. 04_troubleshooting_bash

Troubleshooting and Bash
========================

Troubleshooting
---------------

* This is a lot like debugging a problem in code
* 

General Steps
-------------

#. Understand the problem
#. Reproduce the problem
#. Isolate the change that created the problem
#. Test the fix
#. Automate the fix to your entire infrastructure

Example Problem
---------------

* Nagios alert goes off that SSH isn't working
* Confirm SSH isn't working
* Log in over serial via the BMC

Symptoms
--------

* Almost all executables return ``Input/Output Error``
* Only working (useful) utils: ``cat``, ``ssh``, bash builtins
* Can't read most files (only ones that are already in memory)
* Ideas..?

(Temporary) Fixing
------------------

* A reboot (temporarily) fixed the issue
* No logs (couldn't write to disk)
* No useful logs went to remote servers
* No logs in the Server Event Log (BMC log)
* Raid card reports 1 disk that will fail soon

Possible Causes
---------------

* Likely a RAID card lockup
* Bad controller?
* Bad disk?
* Buggy controller?
* Bad PCIE bridge? (nope)

Real Fix
--------

* Contact vendor and start RMA process for controller
* See if problem reproduces

Example Problem 2
-----------------

* Google Analytics reports a growing number of 404 links
* Links are growing exponentially (small number, 1k, 9k, 50k, ...)  per day
* None of the reported links can be found on the site.

Symptoms
--------

* Link growth pattern
* Reported links sometimes have patterns, ``/path/page/2, /path/page/3, ...``

Debugging
---------

* Change browser string to be the same as Google Bot
* Nothing changes

* Use ``curl`` to inspect page at a lower level, notice temporary redirects
* Browsers follow redirect without reading page, bots read page.

Cause
-----

* Every temporary redirect page was still generating page content

  * Including links that were invalid (404!)

Fix
---

* Changed webapp to use permanent redirect, not temporary
* Wait for GA 404 reports to go back down.

Bash
====

Basics
------

* Interpreted Language
* Built to easily interact with a system, run other programs
* Pipes!

Useful Symbols
--------------

* ``|`` Pipe -- redirects stdout of left to stdin of right

  * ``grep 'searchstring' files/* | less``

* ``&&`` and ``||`` -- Logical AND and OR

  * ``true || echo "never gets here"``
  * ``false && echo 'runs if false fails, which it always does'``

* ``2>`` and ``1>`` -- Redirect STDERR and STDOUT

  * ``fping -g 10.0.0.0/24 2>&1 | grep unreachable`` Normally ``fping`` outputs
    an error message for each unreachable host. ``2>&1`` redirects STDERR to STDOUT
    so we can grep it

More Useful Symbols
-------------------

* ``!$`` -- Last argument to last command

  * ``cat /dir/; cd !$`` Did you use ``cat`` when you meant ``cd``? Easy fix!

* ``for; do; done`` -- for loop

  * ``for x in $(find . -type f); do echo $x is a file; done``

* ``${var//}`` -- Delete text from var

  * ``var="this is a var"; echo ${var//this is }``

* ``$()`` and `````` -- Run this as another bash command, and insert its output in place

  * ``ls -l `which bash```

Combining These Together
------------------------

.. code-block:: bash

    $ set -a blocks
    $ blocks="10.0.0.0/24"
    $ set -a ips
    $ ips=`fping -g 10.0.0.0/24 2>&1 | grep unreachable | tr \\  \\n`
    $ for ip in $ips; do nmap -p 22 $ip && ips=`echo ${ips//$ip} | tr -s \\n`
    $ echo $ips

Function Definitions
--------------------

.. code-block:: bash

    name () {
    # code goes here
    }

Internal Variables
------------------

You should know the following:

.. csv-table::
   :header: Variable,Meaning

   ``$*``,All arguments passed
   ``$?``,Return code of last command run
   ``"$@"``,All arguments passed as a list
   ``$CDPATH``,Colon-delimited list of places to look for dirs
   ``$HOME``, Location of user homedir
   ``$IFS``,Internal Field Seperator
   ``$OLDPWD``,Previous PWD

Internal Variables
------------------

.. csv-table::
   :header: Variable,Meaning

   ``$PATH``,Colon-delimited list of places to find executables
   ``$PWD``,Present Working Directory
   ``$SHELL``,Path to running shell
   ``$UID``, User ID
   ``$USER``,Username

Useful Userland Utils
---------------------

.. code-block:: none

    awk
    cat
    cd
    cut
    grep
    ls
    lsw
    lsx
    mtr
    nc/netcat
    pwd
    rev
    sed
    seq
    sort
    tar
    tr
    uniq
    w
    wc
    
IFS
---

* Every char in ``$IFS`` bash considers a seperator between words.

.. code-block:: bash

    #!/bin/bash
    
    var1=1-2-3
    var2=2+3+4
    
    IFS=-
    
    echo $var1
    echo $var2
    
    IFS=+
    
    echo $var1
    echo $var2
