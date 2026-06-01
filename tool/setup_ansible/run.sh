#!/usr/bin/env bash
# =============================================================================
# run.sh  ─  tool/.env を読み込んで ansible-playbook を実行する
# 使い方: bash run.sh [ansible-playbookの追加オプション]
# 例:     bash run.sh --check        # ドライラン
#         bash run.sh --limit web01  # 特定ホストのみ
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"

# ── .env 読み込み ──────────────────────────────────────────────────────────
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "❌  ${ENV_FILE} が見つかりません。tool/.env を作成してください。"
  exit 1
fi

echo "📄  ${ENV_FILE} を読み込み中..."
# コメント行・空行を除外して export
set -a
# shellcheck disable=SC1090
source <(grep -v '^\s*#' "${ENV_FILE}" | grep -v '^\s*$')
set +a

# ── 必須変数チェック ───────────────────────────────────────────────────────
required_vars=(HOST USER CF_TUNNEL_TOKEN)
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "❌  ${ENV_FILE} に ${var} が設定されていません。"
    exit 1
  fi
done

# ── inventory.ini を動的生成 ───────────────────────────────────────────────
INVENTORY_FILE="${SCRIPT_DIR}/../../ansible/inventory.ini"

cat > "${INVENTORY_FILE}" <<EOF
# このファイルは run.sh によって tool/.env から自動生成されます
# 直接編集しないこと

[servers]
target ansible_host=${HOST} ansible_user=${USER} ${KEY:+ansible_ssh_private_key_file=${KEY}}

[servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "✅  inventory.ini を生成しました (host: ${HOST}, user: ${USER})"
