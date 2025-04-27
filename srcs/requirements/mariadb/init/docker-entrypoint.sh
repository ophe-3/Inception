#!/bin/bash
set -eo pipefail

# S'assurer que le répertoire pour le socket existe
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Créer un fichier indicateur pour déterminer si c'est la première exécution
INIT_FILE="/var/lib/mysql/.initialized"

if [ ! -f "$INIT_FILE" ]; then
    echo "Première initialisation de MariaDB..."
   
    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
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

        echo "Configuration initiale de MariaDB..."
        
        # Configurer le mot de passe root
        echo "Configuration du mot de passe root..."
        mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root password "$MYSQL_ROOT_PASSWORD"
        echo "Mot de passe root configuré avec succès"
        
        # Configurer l'accès distant pour root
        echo "Configuration de l'accès distant pour root..."
        mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;" 2>/dev/null
        echo "Accès distant pour root configuré avec succès"

        # Créer la base de données
        if [ -n "${MYSQL_DATABASE}" ]; then
            echo "Création de la base de données: ${MYSQL_DATABASE}"
            mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
        fi
        
        # Créer l'utilisateur spécifié et lui donner les droits sur la base
        if [ -n "${MYSQL_USER}" ] && [ -n "${MYSQL_PASSWORD}" ]; then
            echo "Création de l'utilisateur: ${MYSQL_USER}"

            mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" || true
            
            mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" || true
            
            if [ -n "${MYSQL_DATABASE}" ]; then
                echo "Attribution des droits à l'utilisateur sur la base ${MYSQL_DATABASE}"
                mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
            fi

            mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
            
            # Créer le fichier indicateur
            touch "$INIT_FILE"
        fi

        # Arrêter MySQL
        echo "Arrêt de MariaDB temporaire..."
        mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"$MYSQL_ROOT_PASSWORD" shutdown || true

        echo "Configuration de MariaDB terminée."
    fi
else 
    echo "Base de données déjà initialisée"
fi

exec "$@"