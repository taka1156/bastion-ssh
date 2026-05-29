#!/bin/bash

source "$(dirname "$0")/.env"

ssh -i "$SSH_KEY" -p "$SSH_PORT" -o ProxyCommand="cloudflared access ssh --hostname $SUBDOMAIN.$DOMAIN" $SSH_USER@$SSH_HOST
