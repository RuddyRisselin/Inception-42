#!/bin/bash

# Créer le répertoire de socket s'il n'existe pas et donner les bons droits
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialiser la base de données MariaDB si elle n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

# Démarrer MariaDB en arrière-plan
mysqld_safe --skip-networking &
sleep 5

# Attendre que MariaDB soit prêt
until mysql -h "localhost" -u root -e "SELECT 1;" &> /dev/null; do
    echo "En attente de MariaDB..."
    sleep 2
done

echo "MariaDB est prêt, exécution des commandes SQL..."

# Se connecter à MariaDB et exécuter les commandes SQL
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DBNAME}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DBNAME}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Vérifier si les utilisateurs existent bien
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT User, Host FROM mysql.user;"

# S'assurer que tout est bien appliqué avant de fermer
sleep 2
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Démarrer MariaDB en mode normal
exec mysqld
