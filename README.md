# docker-mariadb
A simple, flexible Docker image for MariaDB 10.0

## Create the image
Pull the image from Docker Hub:
```
$ docker pull arccoza/mariadb
```

or


Clone or download the repo to a folder, and from inside that folder run from terminal:

```
$ docker build -t "arccoza/mariadb" .
```

-t names the image with "arccoza/mariadb", you can change this to use your own username.

## Run / create the container

To create and run a new arccoza/mariadb container run from terminal:

```
$ docker run -d --name mariadb \
             -p 127.0.0.1:3306:3306 \
             -e "MYSQL_ROOT_PASSWORD=some password" \
             -e "MYSQL_DATABASE=appdb" \
             -e "MYSQL_USER=appuser" \
             -e "MYSQL_PASSWORD=another password" \
             -e "INNODB_BUFFER_POOL_SIZE=128M" \
             arccoza/mariadb
```

### Environment variables
The variables:
```
MYSQL_ROOT_PASSWORD
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
INNODB_BUFFER_POOL_SIZE
```
are all optional.

**MYSQL_ROOT_PASSWORD**
Sets the password for the *root* user in MariaDB.

**MYSQL_DATABASE**
Sets a database to be created on the server.

**MYSQL_USER & MYSQL_PASSWORD**
The username and password for an additional user created in MariaDB, 
with admin rights on the database created with *MYSQL_DATABASE*.
**Requires** *MYSQL_DATABASE* to be set, if not set then the user won't be created.

**INNODB_BUFFER_POOL_SIZE**
Sets the size of the *innodb_buffer_pool_size* in *my.cnf* MariaDB configuration. 
The default value is 128M.
