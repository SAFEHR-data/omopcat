#!/bin/sh
set -euxo pipefail

if [ "$SERVER_NAME" != "localhost" ]; then
    if [ ! -f /etc/letsencrypt/live/$SERVER_NAME/fullchain.pem ]; then
        echo "Certificates not found, creating them"
        /usr/bin/certbot --nginx --non-interactive --agree-tos -d "$SERVER_NAME"
    fi
    echo "Certificates found, running nginx"
    nginx -g 'daemon off;'
fi

echo "No certificates needed, running nginx"
nginx -g 'daemon off;'
