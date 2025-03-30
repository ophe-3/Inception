#!/bin/bash
set -eo pipefail

# Si la variable MYSQL_ROOT_PASSWORD est définie, configurez l'utilisateur root
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    # Vérifier si la base de données est déjà initialisée
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Initialisation de la base de données MariaDB..."
        mkdir -p /var/lib/mysql
        chown -R mysql:mysql /var/lib/mysql
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
    fi

    # Démarrer MySQL temporairement avec un socket
    echo "Démarrage temporaire de MariaDB..."
    mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    pid="$!"

    # Attendre que MySQL soit prêt
    for i in {30..0}; do
        if mysqladmin --socket=/var/run/mysqld/mysqld.sock ping &>/dev/null; then
            break
        fi
        echo "En attente du démarrage de MariaDB..."
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo "Impossible de démarrer MariaDB"
        exit 1
    fi

    # Pour une nouvelle installation, mysql_install_db crée un utilisateur root sans mot de passe
    # Configurer le mot de passe root
    echo "Configuration du mot de passe root..."
    
    # Pour MariaDB, utilisez cette commande pour configurer le mot de passe root
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root password "$MYSQL_ROOT_PASSWORD"
    
    # Puis connectez-vous avec le nouveau mot de passe pour configurer l'accès distant
    mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;"
    mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

    # Arrêter MySQL
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

    echo "Configuration de MariaDB terminée."
fi

# S'assurer que le répertoire pour le socket existe
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Exécuter la commande passée
exec "$@"