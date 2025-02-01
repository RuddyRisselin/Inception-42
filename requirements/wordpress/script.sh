#!/bin/bash
cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
./wp-cli.phar core download --allow-root
./wp-cli.phar config create --dbname=$MYSQL_DBNAME --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost="mariadb:3306" --allow-root
./wp-cli.phar core install --url=localhost --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --allow-root

php-fpm8.2 -F

#!/bin/bash
#cd /var/www/html
#curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
#chmod +x wp-cli.phar
#./wp-cli.phar core download --allow-root
#./wp-cli.phar config create --dbname=$MYSQL_DBNAME --dbuser=wpuser --dbpass=password --dbhost=mariadb --allow-root
#./wp-cli.phar core install --url=localhost --title=inception --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root
#php-fpm8.2 -F
