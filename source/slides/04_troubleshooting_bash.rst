.. 04_troubleshooting_bash

Troubleshooting and Bash
========================

Troubleshooting
---------------

* This is a lot like debugging a problem in code

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

.. code-block:: bash

    $ grep 'searchstring' files/* | less

    $ true || echo 'never gets here'
    $ false && echo 'never gets here'

    $ echo 'this now an error message' 2>&1 | grep -v error
    this is now an error message

    !$ # last argument to last command
    $ cat /dir
    cat: /dir/: Is a directory
    $ cd !$
    cd /dir
    $ pwd
    /dir

More Useful Symbols
-------------------

.. code-block:: bash

    $ for x in 1 2 3; do echo $x; done
    1
    2
    3

    $ var='this is a var'; echo ${var//this is } # Deletes 'this is '
    a var

    $ ls -l `which bash`
    -rwxr-xr-x 1 root root 1029624 Nov 12 15:08 /bin/bash

Combining These Together
------------------------

.. code-block:: bash

    $ set -a blocks
    $ blocks="10.0.0.0/24"
    $ set -a ips
    $ ips=`fping -g 10.0.0.0/24 2>&1 | grep unreachable | tr \\  \\n`
    $ for ip in $ips; do nmap -p 22 $ip && ips=`echo ${ips//$ip} \
      | tr -s \\n`
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

You should also read the EXPANSION section of the bash man page.

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

Every char in ``$IFS`` bash considers a seperator between words.

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
