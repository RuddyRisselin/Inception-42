#!/bin/bash

# Définir HTTP_HOST pour éviter l'erreur Undefined array key "HTTP_HOST"
export HTTP_HOST="${WP_URL:-localhost}"

# Attendre que MariaDB soit prêt avant d'exécuter la configuration de WordPress
until mysql -h "mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &> /dev/null; do
    echo "En attente de MariaDB..."
    sleep 2
done

echo "MariaDB est prêt, installation de WordPress..."

cd /var/www/html

# Télécharger WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

# Télécharger WordPress
./wp-cli.phar core download --allow-root

# Vérifier si wp-config.php existe déjà avant de le recréer
if [ ! -f "wp-config.php" ]; then
    echo "Création de wp-config.php..."
    ./wp-cli.phar config create \
        --dbname="$MYSQL_DBNAME" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    echo "wp-config.php existe déjà, pas besoin de le recréer."
fi

# Vérifier si WordPress est déjà installé
if ! ./wp-cli.phar core is-installed --allow-root; then
    echo "Installation de WordPress..."
    ./wp-cli.phar core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress est déjà installé."
fi

# Lancer PHP-FPM
php-fpm8.2 -F
