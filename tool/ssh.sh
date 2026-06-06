#!/bin/bash

source ".env"

if [ "$ENABLE_TUNNEL" = "true" ]; then
  ssh -i "$KEY" -p "$PORT" -o ProxyCommand="cloudflared access ssh --hostname $SUBDOMAIN.$DOMAIN" "$USER@$HOST"
else
  ssh -i "$KEY" -p "$PORT" "$USER@$HOST"
fi
