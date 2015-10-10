#!/bin/bash

# Change bind address to 0.0.0.0
# sed -i -r 's/bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && mv /tmp/my.cnf /etc/mysql/my.cnf

# Change the innodb_buffer_pool_size (default is 256M, INNODB_BUFFER_POOL_SIZE default is 128M).
sed -i -e 's/^innodb_buffer_pool_size\s*=.*/innodb_buffer_pool_size = '$INNODB_BUFFER_POOL_SIZE'/' /etc/mysql/my.cnf

VOLUME_HOME="/var/lib/mysql"

if [ ! -d $VOLUME_HOME/mysql ]; then
	mkdir -p "$VOLUME_HOME"
	chown -R mysql:mysql "$VOLUME_HOME"
	echo "=> An empty or uninitialized MariaDB volume is detected in $VOLUME_HOME"
	echo "=> Installing MariaDB ..."
	mysql_install_db > /dev/null 2>&1
	echo "=> Done!"  
	/mysql_config_users.sh
else
	echo "=> Using an existing volume of MariaDB"
fi

exec mysqld