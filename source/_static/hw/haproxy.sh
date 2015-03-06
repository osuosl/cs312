#!/bin/bash
# HW6 - Setup some simple python HTTP servers to simulate various applications

WORKDIR="/tmp/hw6"
LOGS="${WORKDIR}/logs"
SITES="${WORKDIR}/sites"
mkdir -p $LOGS

# Blog
mkdir -p ${SITES}/blog/
echo "<html><body>Blog Page</body></html>" > ${SITES}/blog/index.html
cd ${SITES}/blog/
python -m SimpleHTTPServer 8000 2> ${LOGS}/blog-8000.log > /dev/null &
python -m SimpleHTTPServer 8001 2> ${LOGS}/blog-8001.log > /dev/null &

# Admin page
mkdir -p ${SITES}/admin/
echo "<html><body>Admin Page</body></html>" > ${SITES}/admin/index.html
cd ${SITES}/admin/
python -m SimpleHTTPServer 8002 2> ${LOGS}/admin-8002.log > /dev/null &

# www site
mkdir -p ${SITES}/www/
echo "<html><body>WWW Page</body></html>" > ${SITES}/www/index.html
cd ${SITES}/www/
python -m SimpleHTTPServer 8003 2> ${LOGS}/www-8003.log > /dev/null &
python -m SimpleHTTPServer 8004 2> ${LOGS}/www-8004.log > /dev/null &
python -m SimpleHTTPServer 8005 2> ${LOGS}/www-8005.log > /dev/null &
python -m SimpleHTTPServer 8006 2> ${LOGS}/www-8006.log > /dev/null &
python -m SimpleHTTPServer 8007 2> ${LOGS}/www-8007.log > /dev/null &
