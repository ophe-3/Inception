# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: opdi-bia <opdi-bia@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/03/30 15:30:44 by opdi-bia           #+#    #+#              #
#    Updated: 2025/04/02 20:28:47 by opdi-bia          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TLS_DIR=./srcs/requirements/nginx/tls

.PHONY:

deps:
	@echo "Installation des dépendances..."
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y ca-certificates curl gnupg lsb-release
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker opdi-bia
	newgrp docker

	@echo "Toutes les dépendances ont été installées avec succès."

requirements:
	@echo "Vérification des dépendances..."
	@command -v openssl >/dev/null 2>&1 || { \
		echo "OpenSSL n'est pas installé. Lancez 'make deps' pour l'installer."; \
		exit 1; \
	}
	@command -v docker >/dev/null 2>&1 || { \
		echo "Docker n'est pas installé. Lancez 'make deps' pour l'installer."; \
		exit 1; \
	}
	@command -v docker compose >/dev/null 2>&1 || { \
		echo "Docker-Compose n'est pas installé. Lancez 'make deps' pour l'installer."; \
		exit 1; \
	}
	@echo "Toutes les dépendances requises sont installées."

clean_tls:
	@echo "Suppression des fichiers TLS..."
	rm -f $(TLS_DIR)/tls.key $(TLS_DIR)/tls.crt
	@echo "TLS nettoyé : tls.key et tls.crt supprimés."

clean_docker: 	
	@echo "Clean des docker-compose ressources"
	docker compose -f ./srcs/docker-compose.yml down -v
	docker compose -f ./srcs/docker-compose.yml rm -f

clean: clean_tls clean_docker
	@echo "Nettoyage des materiels TLS et des ressources dockers terminé."

tls: clean requirements
	@echo "Création du dossier TLS si nécessaire..."
	mkdir -p ./srcs/requirements/nginx/tls

	@echo "Génération de la clé privée..."
	openssl genrsa -out ./srcs/requirements/nginx/tls/tls.key 2048

	@echo "Génération du certificat auto-signé (TLS 1.2)..."
	openssl req -new -x509 -sha256 -days 365 \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=opdi-bia.42.fr/UID=opdi-bia" \
		-key ./srcs/requirements/nginx/tls/tls.key \
		-out ./srcs/requirements/nginx/tls/tls.crt

	@echo "Génération du certificat au format human readable"
	openssl x509 -in ./srcs/requirements/nginx/tls/tls.crt -text -noout > ./srcs/requirements/nginx/tls/crt.text

	@echo "Certificat TLS généré avec succès !"

start: requirements tls	
	@echo "Run docker-compose"
	mkdir -p /home/opdi-bia/data/mariadb /home/opdi-bia/data/wordpress
	docker compose -f ./srcs/docker-compose.yml up --build

