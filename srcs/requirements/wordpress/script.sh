#!/bin/bash

TIMER=0
TIMEOUT=60
until mysql -h "mariadb" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; do
    echo "waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is ready, installation of Wordpress..."

cd /var/www/html

if [ ! -f "wp-cli.phar" ]; then
    echo "downloading WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi

if [ ! -f "wp-config.php" ]; then
    echo "downloading WordPress..."
    ./wp-cli.phar core download --allow-root
fi

if [ ! -f "wp-config.php" ]; then
    echo "Configuration of WordPress..."
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    echo "wp-config.php already exist"
fi

if ! ./wp-cli.phar core is-installed --allow-root; then
    echo "Installation of WordPress..."
    ./wp-cli.phar core install \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress is already install."
fi

if ! ./wp-cli.phar user list --allow-root | grep -q "$WP_USER"; then
    echo "Création of user1 WordPress..."
    ./wp-cli.phar user create "$WP_USER" "$WP_EMAIL" --role="$WP_ROLE" --user_pass="$WP_PASSWORD" --allow-root
else
    echo "$WP_USER already exist."
fi

# Lancer PHP-FPM
php-fpm8.2 -F