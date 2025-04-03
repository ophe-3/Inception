#!/bin/bash

set -e

sleep 10 

cd /var/www/wordpress

# Générer wp-config.php si absent
if [ ! -f wp-config.php ]; then
  echo ">> Génération de wp-config.php via wp-cli"
  wp config create --allow-root \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$MYSQL_PASSWORD \
    --dbhost=mariadb:3306 \
    --path='/var/www/wordpress'
fi

# Installer WordPress si ce n’est pas déjà fait
if ! wp core is-installed --allow-root; then
  echo ">> Installation WordPress"
  wp core install --allow-root \
    --url=$WP_URL \
    --title="$WP_TITLE" \
    --admin_user=$WP_ADMIN \
    --admin_password=$WP_ADMIN_PASSWORD \
    --admin_email=$WP_ADMIN_EMAIL \
    --path='/var/www/wordpress'
  
  echo ">> Création utilisateur secondaire"
  wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD --role=author --allow-root
fi

if [ ! -d /run/php ]; then
    mkdir /run/php
fi

exec "$@"
