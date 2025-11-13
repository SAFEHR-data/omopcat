#!/bin/sh
set -euxo pipefail

if [ "$SERVER_NAME" != "localhost" ]; then
    if [ ! -f /etc/nginx/conf.d/default.conf ]; then
        echo "Config file not found, creating it"
        envsubst '${SERVER_NAME}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf
        /usr/bin/certbot --nginx --non-interactive --agree-tos -d "$SERVER_NAME"
    fi
    echo "Config file found, running nginx"
    nginx -g 'daemon off;'
else
    echo "Running locally, running nginx without config file"
    nginx -g 'daemon off;'
fi

