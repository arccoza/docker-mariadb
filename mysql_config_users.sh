#!/bin/bash

mysqld --skip-grant-tables > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
	echo "=> Waiting for confirmation of MariaDB service startup"
	sleep 5
	mysql -uroot -e "status" > /dev/null 2>&1
	RET=$?
done

if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
	echo "=> Setting root password."
	mysql -uroot -e "USE mysql; UPDATE user SET password=PASSWORD('$MYSQL_ROOT_PASSWORD') where User='root';"
fi

if [ ! -z "$MYSQL_DATABASE" ]; then
	echo "=> Creating $MYSQL_DATABASE."
	mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
fi

if [ ! -z "$MYSQL_USER" -a ! -z "$MYSQL_PASSWORD" -a ! -z "$MYSQL_DATABASE" ]; then
	echo "=> Creating $MYSQL_USER and granting privileges on $MYSQL_DATABASE."
	mysql -uroot -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON '$MYSQL_DATABASE'.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"
fi

echo "=> Done!"

mysqladmin -uroot shutdown