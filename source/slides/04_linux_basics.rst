.. _04_linux_basics:

Troubleshooting and Bash
========================

Troubleshooting
---------------

* This is a lot like debugging a problem in code
* No hard rules

General Steps
-------------

#. Understand the problem
#. Reproduce the problem (this sometimes loops back to step 1)
#. Isolate the change that created the problem
#. Test the fix
#. Automate the fix to your entire infrastructure

Example Problem
---------------

* Users report that a website that generates PDF sends them broken links
* PDFs are stored on a network storage volume using gluster backed by xfs
* 

Symptoms
--------

* All monitoring is returning okay
* Users report 403 Forbidden when trying to download pdf
* permissions on all files look okay

Reproducing the problem
-----------------------

* The problem is reproducible for anyone across all pdf links that
  were reported
* No changes were made recently
* a ``ls /data/<snip>/pdfs/`` returns ``Input/Output Error`` on **some** pdfs

Understanding the problem
-------------------------

* Gluster volume is replicated across two machines: fs3, fs4
* Both partitions on those machines appear to be just fine.
* Gluster reports that a large number (15,000+) of files are marked for healing
* Gluster is unable to automatically heal any of those files

Complications
-------------

* Earlier that day the webnode's disk filled with logs

  - Another sysadmin removed the logfile, didn't keep a backup
  - No centralized logging for this service

* Something went wrong with the gluster volume, but no logs remain
* Both fs machines report something wrong with the other, but no logs as to
  what happened to cause this behavior

More symptoms
-------------

* All pdfs readable on webnode observed to be on both fs machines
* All not-readable pdfs on webnode observed to be on only one fs machine
  (should be replicated to both)
* All pdfs not-readable from webnode are readable from fs machine they
  are found on, no data corruption appears present

Temp Solution
-------------

* rsync all pdfs from both fs machines
* do math to verify that none were lost
* make pdfs available from a different network volume

Permanent Solution
------------------

* Examine broken volume and figure out why it split-brained and couldn't heal
* Change things so this won't happen again

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

    $ echo 'this now an error message' 1>&2 | grep -v error
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

    $ for x in 1 2 3; do echo $x; done # Use seq for longer sequences
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
    $ for ip in $ips; do
    $   nmap -p 22 $ip && ips=`echo ${ips//$ip} \
        | tr -s \\n`
    $ done
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

Advanced Bash Scripting Guide
-----------------------------

The `advanced bash scripting guide <http://www.tldp.org/LDP/abs/html/>`_ is very useful.

In particular, `part 5 <http://www.tldp.org/LDP/abs/html/part5.html>`_ contains a lot of useful information.
