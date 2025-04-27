
FROM debian:oldstable

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx=1.18.0-6.1+deb11u4 \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
