
FROM debian:oldstable 

RUN apt-get update && \
    apt-get install -y wget \
    sudo \
    php7.3 \
    php-fpm \
    php-mysql \
    mariadb-client

RUN wget https://fr.wordpress.org/wordpress-6.7.1-fr_FR.tar.gz -P /var/www \
    && cd /var/www && tar -xzf wordpress-6.7.1-fr_FR.tar.gz \
    && rm wordpress-6.7.1-fr_FR.tar.gz

RUN chown -R root:root /var/www/wordpress \
    && sed -i 's/^;*clear_env\s*=.*/clear_env = no/' /etc/php/7.4/fpm/pool.d/www.conf \
    && sed -i 's|^listen\s*=.*|listen = wordpress:9000|' /etc/php/7.4/fpm/pool.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp 

COPY conf/script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/usr/local/bin/script.sh"]

EXPOSE 9000

CMD ["/usr/sbin/php-fpm7.4","-F"]
