#!/bin/bash

source "$(dirname "$0")/.env"

if [ "$ENABLE_TUNNEL" = "true" ]; then
  rsync -e "ssh -i $KEY -p $PORT -o ProxyCommand='cloudflared access ssh --hostname $SUBDOMAIN.$DOMAIN'" "$@"
else
  rsync -e "ssh -i $KEY -p $PORT" "$@"
fi
