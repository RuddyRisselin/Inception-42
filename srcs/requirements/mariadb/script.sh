#!/bin/bash

if pgrep mysqld > /dev/null; then
    echo "MariaDB is already running"
    killall -9 mysqld mysqld_safe
fi

rm -f /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log.*

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation of database"
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

echo "MariaDB is starting"
mysqld --bind-address=0.0.0.0 &
sleep 5

TIMEOUT=60
TIMER=0
until mysql -h "localhost" -u root -e "SELECT 1;" &> /dev/null; do
    echo "MariaDB is not responding"
    sleep 2
done

echo "MariaDB is ready"

mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysql -u root -p"${DB_PASS}" -e "SELECT User, Host FROM mysql.user;"

sleep 2
mysqladmin -u root -p"${DB_PASS}" shutdown

exec mysqld