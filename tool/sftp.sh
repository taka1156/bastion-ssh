#!/bin/bash

source ".env"

if [ "$ENABLE_TUNNEL" = "true" ]; then
  sftp -i "$KEY" -P "$PORT" -o ProxyCommand="cloudflared access ssh --hostname $SUBDOMAIN.$DOMAIN" "$@"
else
  sftp -i "$KEY" -P "$PORT" "$@"
fi
