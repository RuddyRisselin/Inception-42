#!/bin/bash

# Forcer l'initialisation de la base de données si elle n'existe pas
mysql_install_db --user=mysql --ldata=/var/lib/mysql

# Démarrer MariaDB en arrière-plan
mysqld_safe --skip-networking &
sleep 5

# Se connecter à MariaDB et exécuter les commandes SQL
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DBNAME}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DBNAME}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Arrêter le serveur pour redémarrage propre
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Démarrer MariaDB en mode normal
exec mysqld
