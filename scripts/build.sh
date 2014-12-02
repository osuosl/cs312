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
SPHINXOPTS="-W" make -e html

# Disable venv
deactivate
