#! /bin/bash

# Update repo
git checkout master
git pull -q

# Enable venv
if [ ! -d venv ]; then
    virtualenv venv
fi
source venv/bin/activate

# Update packages
pip install -r requirements.txt

# Build docs
# If we've already built the env, make warnings errors
if [ -e build/html/objects.inv -a -e build/html/slides/objects.inv ] ; then
  SPHINXOPTS="-W" make -e slides
  # If we're on server with varnish, clear out the cache so that it can grab the
  # updated content from the slides
  if [ -x /usr/bin/varnishadm ] ; then
    sudo /usr/bin/varnishadm -T localhost:6082 -S /etc/varnish/secret \
      "ban req.http.host ~ cs312.osuosl.org"
  fi
  SPHINXOPTS="-W" make -e html
else
# Otherwise build without errors since the interwiki file doesn't exist yet and
# it will fail as a warning.
  make slides
  make html
fi

# Disable venv
deactivate
