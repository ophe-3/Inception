# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: opdibia <opdibia@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/03/30 15:30:44 by opdibia           #+#    #+#              #
#    Updated: 2025/03/30 17:30:41 by opdibia          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TLS_DIR=./srcs/requirements/nginx/tls

.PHONY: tls

clean_tls:
	@echo "🧹 Suppression des fichiers TLS..."
	rm -f $(TLS_DIR)/tls.key $(TLS_DIR)/tls.crt
	@echo "✅ TLS nettoyé : tls.key et tls.crt supprimés."

clean_docker: 	
	@echo "RM docker-compose ressources"
	docker-compose -f ./srcs/docker-compose.yml rm -f
	
clean: clean_tls clean_docker
	@echo "🧼 Nettoyage global terminé."

check_openssl:
	@command -v openssl >/dev/null 2>&1 || { \
		echo "❌ OpenSSL n'est pas installé. Lancez 'make install_openssl' pour l'installer."; \
		exit 1; \
	}
	@echo "✅ OpenSSL est installé."

install_openssl:
	@echo "🔧 Installation de OpenSSL via apt..."
	sudo apt update && sudo apt install -y openssl
	@echo "✅ OpenSSL a été installé avec succès."
	
tls: clean check_openssl
	@echo "📁 Création du dossier TLS si nécessaire..."
	mkdir -p ./srcs/requirements/nginx/tls

	@echo "🔐 Génération de la clé privée..."
	openssl genrsa -out ./srcs/requirements/nginx/tls/tls.key 2048

	@echo "📄 Génération du certificat auto-signé (TLS 1.2)..."
	openssl req -new -x509 -sha256 -days 365 \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=opdi-bia.42.fr/UID=opdi-bia" \
		-key ./srcs/requirements/nginx/tls/tls.key \
		-out ./srcs/requirements/nginx/tls/tls.crt

	@echo "📄 Génération du certificat au format human readable"
	openssl x509 -in ./srcs/requirements/nginx/tls/tls.crt -text -noout > ./srcs/requirements/nginx/tls/crt.text

	@echo "✅ Certificat TLS généré avec succès !"

start: tls	
	@echo "Run docker-compose"
	docker-compose -f ./srcs/docker-compose.yml up --build

