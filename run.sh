#!/bin/bash

# Change bind address to 0.0.0.0
# sed -i -r 's/bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

# Comment out bind address
sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

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
else
	echo "=> Using an existing volume of MariaDB"
fi

# Config the MariaDB users.
/mysql_config_users.sh

echo "=> Starting MariaDB..."
exec mysqld