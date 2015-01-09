.. _ssh_keys:

SSH Keys Howto
==============

Why?
----

SSH keys have numerous advantages over passwords

- Increased security: they are nearly impossible to brute force or guess
- Ease of management: Need access to a friend's computer? Just send them your
  public key. No more creating and changing random passwords.
- Type less passwords: You can use ssh-agent to cache your key, so you can use
  ssh without typing your password every time
- Automated scripts: Because you don't need to type your password every time,
  its easier to automate tasks that require ssh

How?
----

Linux/OS X (Short Version)
~~~~~~~~~~~~~~~~~~~~~~~~~~
- Run this command::

    ssh-keygen -t rsa

- Accept the default location (unless you already have an ssh key you have, then
  choose a new file location), and enter a secure passphrase that you (and only
  you) will remember.

Linux/OS X (Detailed)
~~~~~~~~~~~~~~~~~~~~~
- Use the ``ssh-keygen`` utility to create your key. For a 2048 bit RSA key do::

    ssh-keygen -t rsa

For increased security you can make an even larger key with the -b option. For
example, for 4096 bits do::

    ssh-keygen -t rsa -b 4096

The we recommend using RSA over DSA because DSA keys are required to be only
1024 bits.

- When prompted, you can press Enter to use the default location
  (``/home/your_username/.ssh/id_rsa`` on Linux, or
  ``/Users/your_username/.ssh/id_rsa`` on Mac) if you don't already have a key
  installed, or specify a custom location if you are creating a second key (or
  just want to for whatever reason).
- Enter a passphrase at the prompt. **All people connecting to openstack cluster
  must use a passphrase**. This is just a password used to unlock your key. If
  someone else gets a copy of your private key they will be able to log in as
  you on any account that uses that key, unless you specify a passphrase. If you
  specify a passphrase they would need to know both your private key **and**
  your passphrase to log in as you.
- After you re-enter your passphrase, ssh-keygen may print a little picture
  representing your key ((you don't need to worry about this now, but it is
  meant as an easily recognizeable fingerprint of your key, so you could know if
  it is changed without your knowledge - but it doesn't seem to be widely used))
  then exit.
- Your private key should now be in the location you specified, and your public
  key will be at that same location but with '.pub' tacked onto the filename.
- Copy and paste the **public key** so you can add it to Openstack.
- Never share your private key file, only the public key file.

Windows (using putty)
---------------------

`Great guide on setting up Filezilla with ssh keys`__ `Download`__ and start the
puttygen.exe generator.

.. __: http://albertsk.files.wordpress.com/2012/12/putty-filezilla.pdf
.. __: http://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe

- In the "Key" section choose SSH-2 RSA and press Generate.
- Move your mouse randomly in the small screen in order to generate the key
  pairs.
- Enter a key comment, which will identify the key (useful when you use several
  SSH keys).
- Type in the passphrase and confirm it. The passphrase is used to protect your
  key. You will be asked for it when you connect via SSH.
- Click "Save private key" to save your private key.
- Click "Save public key" to save your public key.
- Copy and paste the **public key** so you can add it to Openstack.
- keep your private key in a safe place
- when using putty go to connection->SSH->Auth and Browse to your private key
