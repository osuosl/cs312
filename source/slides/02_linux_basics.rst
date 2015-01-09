.. _02_linux_basics:

Linux Basics (Day 2)
====================

Topics
------

* Packages (leftover from Wednesday)
* Editors
* Git
* Openstack Setup

Package Management
------------------

*Take care of installation and removal of software*

**Core Functionality:**

* Install, Upgrade & uninstall packages easily
* Resolve package dependencies
* Install packages from a central repository
* Search for information on installed packages and files
* Pre-built binaries (usually)
* Find out which package provides a required library or file

Popular Linux Package Managers
------------------------------

**.deb**

* apt - Debian package manager with repo support
* dpkg - low level package manager tool used by apt
* Used by Debian, Ubuntu, Linux Mint and others

**.rpm**

* yum - RPM Package manager with repo support
* rpm - low level package manager tool used by yum
* Used by RedHat, CentOS, Fedora and others

Yum vs. Apt
-----------

**Yum**

* XML repository format
* Automatic metadata syncing
* Supports a plugin module system to make it extensible
* Checks all dependencies before downloading

**Apt**

* Upgrade and Dist-Upgrade

  * Dist-Upgrade applies intelligent upgrading decisions during a major system
    upgrade

* Can completely remove all files including config files
* Provides more features in the package format

RPM & yum (RedHat, CentOS, Fedora)
----------------------------------

.. image:: ../_static/rpm.png
    :align: right
    :width: 30%

**RPM**

  Binary file format which includes metadata about the package and the
  application binaries as well.

.. image:: ../_static/yum.png
    :align: right
    :width: 30%

**Yum**

  RPM package manager used to query a central repository and resolve RPM
  package dependencies.

Yum Commands (Redhat, CentOS, Fedora)
-------------------------------------

.. code-block:: bash

  # Searching for a package
  $ yum search tree

  # Information about a package
  $ yum info tree

  # Installing a package
  $ yum install tree

  # Upgrade all packages to a newer version
  $ yum upgrade

  # Uninstalling a package
  $ yum remove tree

  # Cleaning the RPM database
  $ yum clean all

Apt (Debian, Ubuntu)
--------------------

.. note:: You can also use aptitude as a front-end to dpkg instead of apt-get.

.. code-block:: bash

  # Update package cache database
  $ apt-get update

  # Searching for a package
  $ apt-cache search tree

  # Information about a package
  $ apt-cache show tree

  # Installing a package
  $ apt-get install tree

  # Upgrade all packages to a newer version
  $ apt-get upgrade
  $ apt-get dist-upgrade

  # Uninstalling a package
  $ apt-get remove tree
  $ apt-get purge tree

Dpkg Commands
-------------

Low level package management. No dependency checking or central repository.

.. code-block:: bash

  # Install or upgrade a DEB file
  $ dpkg -i tree_1.6.0-1_amd64.deb

  # Removing a DEB package
  $ dpkg -r tree

  # Purging a DEB package
  $ dpkg -P tree

  # Querying the DPKG database
  $ dpkg-query -l tree

  # Listing all files in a DEB package
  $ dpkg-query -L tree

Editors
=======

Text Editors
------------

.. note::

    Quick intro/history:  ed editor
    Pros: low-bandwidth, installed pretty much everywhere, very fast and powerful
    for complicated and repetitive tasks
    Cons: Steep learning curve, different “modes” can be confusing at first
    Sublime and other desktop editors: nice for serious programming, but learn
    the basics of simple text editors even if you want to be a developer, you
    won't always be able to edit your code on your own desktop

* ed -> Vi -> Vim
* Stallman -> lisp -> emacs

.. figure:: /static/xkcd_378.png
    :align: center
    :scale: 85%

Avoid Pico/Nano, Notepad++, SublimeText

Emacs
-----

.. figure:: /static/emacs_logo.jpeg
    :align: right

.. note::

    Originally released 1976
    name from Editor MACros for TECO editor, originally Tape Editor and
    COrrector at MIT in the '60s

But, along the way, I wrote a text editor, Emacs. The interesting idea about
Emacs was that it had a programming language, and the user's editing commands
would be written in that interpreted programming language, so that you could
load new commands into your editor while you were editing. You could edit the
programs you were using and then go on editing with them.

 -- Richard Stallman, http://www.gnu.org/gnu/rms-lisp.html

Vim
---

.. figure:: /static/vim_logo.jpeg
    :align: right

.. note::

    originally written for Amiga systems (Commodore PCs), 1988
    vim released 1991
    vimscript, Lua (as of Vim 7.3), Perl, Python, Racket, Ruby, Tcl (tool
    command language).
    vi written by Bill Joy in 1976, visual mode for line editor called ex
    line editors are from age of teleprinters, no cursors

* Available almost everywhere
* Lightweight
* Design decisions explained in http://docs.freebsd.org/44doc/usd/12.vi/paper.html
* Modal editor (command, insert, visual)

How to choose
-------------

* What can the people around you help with?
* Try both; choose one and get good at it
* Have a good answer when people ask why you made that choice
    * "Because it's familiar" is tolerated
    * "Because I was initially taught it" is common but accepted (honesty)
    * "Because ``$usecase``" provokes argument but more respected
    * "Because I tried both and picked this one" is rare but good
* Your use case as a sysadmin or developer

Modes
-----

.. figure:: /static/vim_modes.png
    :align: center
    :scale: 75%

How to tell?

.. code-block:: bash

    -- INSERT --                                          144,1    36%
    -- VISUAL --                                          144,77   36%

Commands
--------

.. note::
    Moving around in a file
    Search / replace
    Text manipulation, ie: cw, dw, c$, yy / p, x, .

.. figure:: /static/vim_cheatsheet.gif
    :scale: 75%

Moving Around
-------------

::

    h move one character to the left.
    j move down one line.
    k move up one line.
    l move one character to the right.
    0 move to the beginning of the line.
    $ move to the end of the line.
    w move forward one word.
    b move backward one word.
    G move to the end of the file.
    gg move to the beginning of the file.
    . move to the last edit.

Configuration / customization
-----------------------------

.. note:: there are many many options and pre-existing packages to make
    editing nice for sysadmins and developers

* ``.vimrc``
* ``:set``

Some sets of Vim plugins and configurations are available

* https://github.com/astrails/dotvim
* https://github.com/carlhuda/janus

Use them for research on what's available to improve dev productivity

Learning Resources
------------------

* ``$ vimtutor``
* http://vim-adventures.com/

.. figure:: /static/learning_curves.jpg
    :align: center
    :scale: 140%

Regular expressions
-------------------

You should know basic substitution:

::

    :%s/foo/bar/g

On IRC, Hamper does rudimentary regex in the form ``s/foo/bar/`` applying only
to the most recent comment.

This is **not** `shell globbing`_

:Resources for learning:
  * `RegExr`_ - an interactive Regular Expression editor and debugger
  * `Regular-Expressions.info`_ - Tutorials and general information

.. _shell globbing: http://tldp.org/LDP/abs/html/globbingref.html
.. _RegExr: http://gskinner.com/RegExr/
.. _Regular-Expressions.info: http://www.regular-expressions.info/



Emacs Moving Around
-------------------

::

    C-f            forward one char (right)
    C-b            backwards one char (left)
    M-f            forward one word
    M-b            backwards one word
    C-n            forward one line (down)
    C-p            backwards one line (up)
    C-a            beginning of line
    C-e            end of line
    C-o            insert-newline and stay on current line
    C-j            insert newline and indent
    C-v            page down
    M-v            page up
    M-<            beginning of file
    M->            end of file
    M-g g <number> goto line <number>
    C-s            forward search (C-s to keep searching)

Emacs Buffers
-------------

* Like a tab on a browser
* Each file gets a buffer
* Special buffers begin and end with ``*``

|

::

    C-x b switch buffers (type a new name to open a new buffer)
    C-x C-b list all buffers
    C-x C-f find file (opens a new buffer for the file)
    C-x k kill buffer
    C-x 1 close all windows but the main one
    C-x 2 split window horizontally
    C-x 3 split window vertically
    C-x o switch window

Emacs Modes
-----------

|

* **NOT** like Vim Modes
* Each buffer has:

  * 1 major mode
  * 0 or more minor modes

Major Modes
-----------

|

* Major Modes determine functionality of buffer, e.g.:

  * syntax highlighting, auto-compiling/linting
  * shell mode
  * Org mode
  * Fundamental
  * Lisp Interaction

Minor Modes
-----------

|

* Minor modes add functionality that multiple modes might use, e.g.:

  * linum-mode (line numbers)
  * whitespace-mode (highlights extraneous whitespace, long lines)

Fun Emacs Magic
---------------

|

::

    M-x eshell <RET> ;; yes, this gives a shell
    M-x server-mode <RET> ;; and then use emacsclient
    M-x compile ;; just "works" for most languages
    M-x package-install ;; emacs has packages!

Emacs Cheat Sheet
-----------------

|

.. figure:: static/emacs.png

Emacs Configuration
-------------------

|

* ``.emacs``, ``.emacs.d/init.el``
* ``M-x``

  * e.g ``M-x linum-mode`` for line numbers
  * ``M-x whitespace-mode`` for whitespace mode

* Elisp (Emacs Lisp)

Emacs Resources
---------------

|

* Emacs manual (``C-h r`` in emacs or `https://www.gnu.org/software/emacs/manual/`)

  * GNU sells printed manuals as well

* Emacs Wiki (`https://www.emacswiki.org`)
* Emacs Tutorial (``C-h t`` inside emacs)

Editor questions?
-----------------

|

* Open an editor, find a cheat sheet, try to add some text
* Modify the text: "``disemvowel``" it

.. code-block:: bash

    $ vim testvim.txt            $ emacs testemacs.txt
    <i>                          Hello world!
    Hello world!                 <alt + x>
    <esc>                        replace-regexp
    :%s/[aeiou]//g               <enter>
    <enter>                      [aeiou]
    :wq                          <enter>
    <enter>                      <ctrl + x> <ctrl + s>
                                 <ctrl + x> <ctrl + c>

Git
===

.. figure:: /static/Linus_Torvalds.jpeg
    :align: left

git, noun. Brit.informal.
1. an unpleasant or contemptible person.

Setting up Git
==============

* In VM:

.. code-block:: bash

    $ sudo yum install git
    $ git config --global user.name "My Name"
    $ git config --global user.email "myself@gmail.com"
    $ git config --global core.editor "nano"

Using Git Locally
=================

``$ git init``

.. note:: This initializes a git repo. Use `man git-init` for more info.

``$ git add <filename>``

.. note:: This puts <filename> into the staging area. It isn't committed yet.
    Use ``git diff`` to see what changes aren't yet in staging.

``$ git commit -m "I did a thing!"``

.. note:: This actually makes the commit. Use ``git status`` to see what's in
    staging but not yet committed. Use ``git show`` or ``git log`` to see
    recent commits.

* Undo things?
  the `git book <http://git-scm.com/book/en/Git-Basics-Undoing-Things>`_ explains
  well

* Did I remember to commit that?
``$ git status``

* What commits have I made lately?
``$ git log``

What Not To Do
==============

* Don't delete the .git files

.. note:: If you kill them, git loses its memory :(

* Avoid redundant copies of the same work in one revision
* Don't make "oops, undoing that" commits.
    * Use git commit --amend or git revert

.. note:: Amending is fine as long as you haven't pushed yet. It's generally a
    bad idea to amend or rebase work that you've already shared with others,
    unless you really know what you're doing.

* Don't wait too long between commits
    * You can squash them all together later

.. note:: Commit every time you think you might want to return to the current 
    state. You can revert back to any previous commit, but there is no way to
    magically add a commit in where you forgot to make one.

* Don't commit secrets...

.. note:: Yes, there are ways to sort of take them down off of GitHub, but
    somebody might have cloned your repo while it had the secrets in. Once
    someone has a piece of information, you can't just take it away.

.. figure:: /static/dont_do_this.jpg
    :scale: 50%
    :align: right

http://arstechnica.com/security/2013/01/psa-dont-upload-your-important-passwords-to-github/

Daily workflow
==============

.. figure:: /static/gitflow.png
    :scale: 75%
    :align: right

Pull -> Work -> Add changes -> Commit -> Push

Larger projects have more complex workflows

.. note:: The picture is of the Git Flow branching model, and you'll probably
    see it every single time anyone explains Git branching and merging to you.
