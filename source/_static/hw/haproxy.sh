#!/bin/bash
# PROJ3 - Setup some simple python HTTP servers to simulate various applications

WORKDIR="/tmp/proj3"
SITES="${WORKDIR}/sites"

# Blog
mkdir -p ${SITES}/blog/
echo "<html><body>Blog Page</body></html>" > ${SITES}/blog/index.html
# Admin page
mkdir -p ${SITES}/intranet/
echo "<html><body>Intranet Page</body></html>" > ${SITES}/intranet/index.html
# www site
mkdir -p ${SITES}/www/
echo "<html><body>WWW Page</body></html>" > ${SITES}/www/index.html

for i in blog intranet www ; do
  cat << EOF > /etc/systemd/system/cs312-${i}@.service
[Unit]
Description=cs312-${i} %I

[Service]
ExecStart=/usr/bin/python -m SimpleHTTPServer %I
WorkingDirectory=/tmp/proj3/sites/${i}
Type=simple
User=nobody
Group=nobody

[Install]
WantedBy=multi-user.target
EOF
done

systemd_path=/etc/systemd/system
ln -sf ${systemd_path}/cs312-blog@.service ${systemd_path}/cs312-blog@8000.service
ln -sf ${systemd_path}/cs312-blog@.service ${systemd_path}/cs312-blog@8001.service
ln -sf ${systemd_path}/cs312-intranet@.service ${systemd_path}/cs312-intranet@8002.service
ln -sf ${systemd_path}/cs312-www@.service ${systemd_path}/cs312-www@8003.service
ln -sf ${systemd_path}/cs312-www@.service ${systemd_path}/cs312-www@8004.service
ln -sf ${systemd_path}/cs312-www@.service ${systemd_path}/cs312-www@8005.service
ln -sf ${systemd_path}/cs312-www@.service ${systemd_path}/cs312-www@8006.service
ln -sf ${systemd_path}/cs312-www@.service ${systemd_path}/cs312-www@8007.service

systemctl daemon-reload
systemctl start cs312-blog@8000
systemctl start cs312-blog@8001
systemctl start cs312-intranet@8002
systemctl start cs312-www@8003
systemctl start cs312-www@8004
systemctl start cs312-www@8005
systemctl start cs312-www@8006
systemctl start cs312-www@8007
