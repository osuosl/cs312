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
  SPHINXOPTS="-W" make -e html
else
# Otherwise build without errors since the interwiki file doesn't exist yet and
# it will fail as a warning.
  make slides
  make html
fi

# Disable venv
deactivate
