#!/bin/bash -x

. /etc/symphony.cfg

SOURCE=1
PULP=1

YUMBASE=/opt/symphony/generic/etc/yum/centos7-base.conf

############# BEGIN SOURCE ###################
if [ $SOURCE -gt 0 ]; then
  mkdir /opt/symphony
  cd /opt/symphony
  git clone https://github.com/alces-software/symphony4.git generic
  git clone https://github.com/alces-software/symphony-repo.git repo
fi
############# END SOURCE ###################

############# BEGIN PULP ###################
if [ $PULP -gt 0 ]; then
  yum -y --config=$YUMBASE install httpd
  chown apache:apache /var/lib/pulp/content
  yum -y --config=$YUMBASE --enablerepo epel --enablerepo pulp install mongodb-server
  systemctl enable mongod
  systemctl start mongod
  yum -y --config=$YUMBASE --enablerepo epel --enablerepo pulp install qpid-cpp-server qpid-cpp-server-linearstore augeas
  ln -snf /etc/qpid/qpidd.conf /etc/qpidd.conf
  augtool -s set /files/etc/qpidd.conf/auth no
  systemctl enable qpidd
  systemctl start qpidd
  yum -y --config=$YUMBASE --enablerepo epel --enablerepo pulp groupinstall pulp-server-qpid
  umount /var/lib/pulp/content
  sudo -u apache pulp-manage-db
  mkdir /var/lib/pulp/content
  chown apache:apache /var/lib/pulp/content
  mount /var/lib/pulp/content
  firewall-cmd --add-service http --zone bld --permanent
  firewall-cmd --add-service https --zone bld --permanent
  firewall-cmd --add-service ssh --zone bld --permanent
  firewall-cmd --add-port 5672/tcp --zone bld --permanent
  firewall-cmd --reload
  systemctl enable httpd
  systemctl restart httpd
  systemctl enable pulp_workers
  systemctl start pulp_workers
  systemctl enable pulp_celerybeat
  systemctl start pulp_celerybeat
  systemctl enable pulp_resource_manager
  systemctl start pulp_resource_manager
  yum -y --config=$YUMBASE --enablerepo epel --enablerepo pulp groupinstall pulp-admin
  cat << EOF > /etc/pulp/admin/admin.conf
[server]
host: repo.bld.$CLUSTER.compute.estate
verify_ssl: false

[client]

[filesystem]

[output]
EOF
  /opt/symphony/repo/bin/write_configs.sh
  if ! [ -f /var/www/html/configs/ ]; then
    ln -snf /opt/symphony/repo/yumconfigs /var/www/html/configs
  fi
fi
pulp-admin login -u admin -p admin
pulp-admin auth user update --login admin --password "${ADMINPASSWORD}"
############# END PULP ###################

#fix resolv.conf
  cat << EOF > /etc/resolv.conf
search bld.cluster.compute.estate prv.cluster.compute.estate mgt.cluster.compute.estate pub.cluster.compute.estate cluster.compute.estate
nameserver 10.78.254.1
EOF