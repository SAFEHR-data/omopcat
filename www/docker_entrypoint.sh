#!/bin/sh
set -euxo pipefail

if [ "$SERVER_NAME" != "localhost" ]; then
  /usr/bin/certbot --nginx --non-interactive --agree-tos -d $SERVER_NAME
fi

nginx -g 'daemon off;'