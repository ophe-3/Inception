FROM debian:oldstable

# Installation des paquets nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Configurer MariaDB pour écouter sur toutes les interfaces
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Créer un script d'initialisation
COPY init/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exposer le port 3306
EXPOSE 3306

# Volume pour les données
VOLUME /var/lib/mysql

# Définir le script d'entrée comme point d'entrée
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Commande par défaut
CMD ["mysqld"]