#!/bin/bash

ENV_EXAMPLE=".env.example"

# Determine output path from argument
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    OUTPUT="$1/.env"
  else
    OUTPUT="$1"
  fi
else
  OUTPUT=".env"
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

# ── Security: disable AI features ─────────────────────────────────────────
echo ""
echo "⚠️  This project stores sensitive credentials in .env."
echo "    To prevent AI tools (GitHub Copilot, etc.) from reading them,"
echo "    it is strongly recommended to disable AI features in VS Code settings"
echo "    and remove AI skill/agent definition files from this workspace."
echo ""
echo "    This will:"
echo "      - Add 'github.copilot.enable: false' and 'chat.disableAIFeatures: true'"
echo "        to .vscode/settings.json"
echo "      - Delete .github/agents/ and .github/skills/bastion-ssh/SKILL.md"
echo ""
read -rp "Apply these security settings? [y/N]: " APPLY_SECURITY
case "$APPLY_SECURITY" in
  [yY]*)
    # Patch .vscode/settings.json
    SETTINGS_FILE=".vscode/settings.json"
    mkdir -p .vscode
    if [ -f "$SETTINGS_FILE" ]; then
      # Use python3 to merge JSON safely
      python3 - "$SETTINGS_FILE" <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
data["github.copilot.enable"] = {"*": False}
data["chat.disableAIFeatures"] = True
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("✅  .vscode/settings.json updated.")
PYEOF
    else
      cat > "$SETTINGS_FILE" <<'JSON'
{
  "github.copilot.enable": {
    "*": false
  },
  "chat.disableAIFeatures": true
}
JSON
      echo "✅  .vscode/settings.json created."
    fi

    # Remove AI agent/skill files
    if [ -d ".github/agents" ]; then
      rm -rf ".github/agents"
      echo "✅  .github/agents/ removed."
    fi
    if [ -f ".github/skills/bastion-ssh/SKILL.md" ]; then
      rm -f ".github/skills/bastion-ssh/SKILL.md"
      echo "✅  .github/skills/bastion-ssh/SKILL.md removed."
    fi
    ;;
  *)
    echo "⏭️  Skipped. You can apply these settings manually later."
    ;;
esac

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
  read -rp "CF_TUNNEL_TOKEN: " CF_TUNNEL_TOKEN
fi

echo ""
echo "=== Ansible Settings (optional) ==="
read -rp "Configure Ansible settings? [y/N]: " USE_ANSIBLE
case "$USE_ANSIBLE" in
  [yY]*) ENABLE_ANSIBLE=true ;;
  *)     ENABLE_ANSIBLE=false ;;
esac

if [ "$ENABLE_ANSIBLE" = "true" ]; then
  read -rsp "SUDO_PASS (sudo password for remote user): " SUDO_PASS
  echo ""

  if [ "$ENABLE_TUNNEL" = "true" ]; then
    read -rp "CF_TUNNEL_TOKEN (Cloudflare Tunnel token for Ansible provisioning): " CF_TUNNEL_TOKEN_ANSIBLE
    CF_TUNNEL_TOKEN="${CF_TUNNEL_TOKEN:-$CF_TUNNEL_TOKEN_ANSIBLE}"
  fi
fi

# Write .env
mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" <<EOF
##############################
# SSH
##############################
HOST=$HOST
USER=$USER
PORT=$PORT
KEY=$KEY

##############################
# Cloudflare Tunnel (optional)
##############################
ENABLE_TUNNEL=$ENABLE_TUNNEL
EOF

if [ "$ENABLE_TUNNEL" = "true" ]; then
  cat >> "$OUTPUT" <<EOF
SUBDOMAIN=$SUBDOMAIN
DOMAIN=$DOMAIN
EOF
fi

cat >> "$OUTPUT" <<EOF

##############################
# Ansible
##############################
EOF

if [ "$ENABLE_ANSIBLE" = "true" ]; then
  cat >> "$OUTPUT" <<EOF
# sudo password for the remote user (required)
SUDO_PASS=$SUDO_PASS
EOF

  if [ "$ENABLE_TUNNEL" = "true" ] && [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
    cat >> "$OUTPUT" <<EOF
# Cloudflare Tunnel token (required when enable_cloudflare_tunnel=true)
CF_TUNNEL_TOKEN=$CF_TUNNEL_TOKEN
EOF
  fi
else
  cat >> "$OUTPUT" <<EOF
# Ansible skipped during setup. Add SUDO_PASS (and CF_TUNNEL_TOKEN if needed) manually.
# SUDO_PASS=
# CF_TUNNEL_TOKEN=
EOF
fi

echo ""
echo "Saved to $OUTPUT"
