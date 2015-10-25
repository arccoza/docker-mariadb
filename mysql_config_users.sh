#!/bin/bash

# Start the daemon without auth or networking.
mysqld --skip-grant-tables --skip-networking > /dev/null 2>&1 &
echo "=> mysqld started."
# Make sure the daemon is fully running before continuing.
RET=1
while [[ RET -ne 0 ]]; do
	echo "=> Waiting for confirmation of MariaDB service startup..."
	sleep 5
	mysql -uroot -e "status" > /dev/null 2>&1
	RET=$?
done

# Clear the mysql.user table of all users except root.
echo "=> Clear mysql.user table (except root)."
mysql -uroot -e "DELETE FROM mysql.user WHERE User != 'root';"

if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
	echo "=> Setting root password."
	mysql -uroot -e "USE mysql; UPDATE user SET password=PASSWORD('$MYSQL_ROOT_PASSWORD') where User='root';"
fi

# Add the database if MYSQL_DATABASE is set.
if [ ! -z "$MYSQL_DATABASE" ]; then
	echo "=> Creating $MYSQL_DATABASE."
	mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
fi

# Stop the daemon.
mysqladmin -uroot shutdown
echo "=> mysqld stopped."

if [ ! -z "$MYSQL_USER" -a ! -z "$MYSQL_PASSWORD" -a ! -z "$MYSQL_DATABASE" ]; then
	# Start the daemon normally, so we can add users using GRANT, since that isn't available with --skip-grant-tables.
	mysqld > /dev/null 2>&1 &
	echo "=> mysqld started."
	# Make sure the daemon is fully running before continuing.
	RET=1
	while [[ RET -ne 0 ]]; do
		echo "=> Waiting for confirmation of MariaDB service startup..."
		sleep 5
		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "status" > /dev/null 2>&1
		RET=$?
	done

	# Add the MYSQL_DATABASE user if it exists and the user vars are set.
	if [ ! -z "$MYSQL_USER" -a ! -z "$MYSQL_PASSWORD" -a ! -z "$MYSQL_DATABASE" ]; then
		echo "=> Creating $MYSQL_USER and granting privileges on $MYSQL_DATABASE."
		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"
	fi

	echo "=> Done!"

	# Stop the daemon.
	mysqladmin -uroot shutdown -p"$MYSQL_ROOT_PASSWORD"
	echo "=> mysqld stopped."
fi
