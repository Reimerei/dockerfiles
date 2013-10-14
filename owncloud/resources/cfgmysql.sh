#!/bin/bash -x
/usr/bin/mysqld_safe &
sleep 5
/usr/bin/mysql -u root -p$MYSQL_ROOT -e "CREATE DATABASE owncloud; GRANT ALL ON owncloud.* TO 'owncloud'@'localhost' IDENTIFIED BY '$MYSQL_OWNCLOUD';"
pkill -f mysqld
