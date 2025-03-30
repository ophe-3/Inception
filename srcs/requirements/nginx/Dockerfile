# syntax=docker/dockerfile:1
FROM debian:oldstable

# Installer nginx (version fixe depuis les dépôts Debian Bullseye)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx=1.18.0-6.1+deb11u4 \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Créer les répertoire TLS pour monter cert et cle
RUN mkdir -p /etc/nginx/ssl

# Exposer les ports HTTP et HTTPS
EXPOSE 80 443

# Lancer nginx en mode non-daemon
CMD ["nginx", "-g", "daemon off;"]
