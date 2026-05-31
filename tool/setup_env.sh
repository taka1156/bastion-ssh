#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

# Determine output path from argument
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    OUTPUT="$1/.env"
  else
    OUTPUT="$1"
  fi
else
  OUTPUT="$SCRIPT_DIR/.env"
fi

# Check .env.example exists
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "Error: $ENV_EXAMPLE not found."
  exit 1
fi

# Confirm overwrite if file already exists
if [ -f "$OUTPUT" ]; then
  read -rp "$OUTPUT already exists. Overwrite? [y/N]: " OVERWRITE
  case "$OVERWRITE" in
    [yY]*) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

echo ""
echo "=== SSH Settings ==="

read -rp "HOST (IP address) [xxx.xxx.xxx.xxx]: " HOST
HOST="${HOST:-xxx.xxx.xxx.xxx}"

read -rp "USER [hoge]: " USER
USER="${USER:-hoge}"

read -rp "PORT [22]: " PORT
PORT="${PORT:-22}"

read -rp "KEY (path to private key) [/root/.ssh/your-key.pem]: " KEY
KEY="${KEY:-/root/.ssh/your-key.pem}"

echo ""
echo "=== Cloudflare Tunnel (optional) ==="
read -rp "Enable Cloudflare Tunnel? [y/N]: " USE_TUNNEL
case "$USE_TUNNEL" in
  [yY]*) ENABLE_TUNNEL=true ;;
  *)     ENABLE_TUNNEL=false ;;
esac

if [ "$ENABLE_TUNNEL" = "true" ]; then
  read -rp "SUBDOMAIN: " SUBDOMAIN
  read -rp "DOMAIN: " DOMAIN
fi

# Write .env
mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" <<EOF
##############################
# Environment variables for Cloudflare Tunnel
##############################
ENABLE_TUNNEL=$ENABLE_TUNNEL

##############################
# SSH
##############################
HOST=$HOST
USER=$USER
PORT=$PORT
KEY=$KEY
EOF

if [ "$ENABLE_TUNNEL" = "true" ]; then
  cat >> "$OUTPUT" <<EOF

##############################
# Cloudflare Tunnel
##############################
SUBDOMAIN=$SUBDOMAIN
DOMAIN=$DOMAIN
EOF
fi

echo ""
echo "Saved to $OUTPUT"
