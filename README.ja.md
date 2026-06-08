# bastion-ssh

[English version here](README.md)

Dev Container を使った汎用 SSH 踏み台ツールです。ローカル環境を汚さずにリモートサーバーへ接続できます。GitHub Codespaces からも利用可能です。

> **Dev Container 対応**  
> このリポジトリは [Dev Containers](https://containers.dev/) を使用しています。  
> VS Code + Dev Containers 拡張機能でコンテナを起動し、その中から操作してください。

## セットアップ

### 1. 接続情報の設定

対話形式で `.env` を生成します。

```shell
make setup
```

セットアップ中、セキュリティ設定を適用するか設問されます:

```
⚠️  This project stores sensitive credentials in .env.
    To prevent AI tools (GitHub Copilot, etc.) from reading them,
    it is strongly recommended to disable AI features in VS Code settings
    and remove AI skill/agent definition files from this workspace.

Apply these security settings? [y/N]:
```

`y` を選択すると、以下が自動で実行されます:

- `.vscode/settings.json` に以下を追加:
  ```json
  "github.copilot.enable": { "*": false },
  "chat.disableAIFeatures": true
  ```
- `.github/agents/` と `.github/skills/bastion-ssh/SKILL.md` を削除

> **なぜ必要か?** `.env` には SSH 秘密鍵パス、sudo パスワード、Cloudflare トークンなどの機密情報が含まれます。このワークスペースでの AI 機能を無効化することで、これらの値が AI ツールに読み取られるリスクを予防します。

生成される `.env` の内容:

```shell
# .env
HOST=xxx.xxx.xxx.xxx
USER={user}
PORT=9999
KEY=/root/.ssh/your-key.pem
```

> 秘密鍵のパーミッションエラーが出る場合は以下を実行してください:
> ```shell
> chmod 600 /root/.ssh/your-key.pem
> ```

### 2. SSH 接続

```shell
make ssh
```

## ファイル転送

### rsync

```shell
# アップロード
make rsync ARGS="-av ./local/path/ {user}@{host}:/remote/path/"

# ダウンロード
make rsync ARGS="-av {user}@{host}:/remote/path/ ./local/path/"
```

### SFTP

```shell
make sftp ARGS="{user}@{host}"
```

## オプション: Cloudflare Tunnel 経由での接続

Cloudflare Tunnel を使うことで、VPS の SSH ポートをインターネットに直接公開せずに接続できます。

### 前提条件

- Cloudflare Zero Trust でトンネルが作成済みであること
- トンネルの Public Hostname に SSH 用のホスト名が登録済みであること
- Dev Container に `cloudflared` がインストール済みであること

### 設定

`make setup` 実行時に Cloudflare Tunnel の有効化を選択すると、以下の変数が追加されます。

```shell
# .env
ENABLE_TUNNEL=true

HOST=xxx.xxx.xxx.xxx
USER={user}
PORT=22
KEY=/root/.ssh/your-key.pem

# Cloudflare Tunnel
SUBDOMAIN=subdomain
DOMAIN=example.com
```

`ENABLE_TUNNEL=true` に設定すると、`make ssh` / `make rsync` / `make sftp` はすべて自動的に Cloudflare Tunnel 経由で動作します。

## Ansible プロビジョニング

付属の Ansible プレイブックを使って、リモートサーバーへの `cloudflared` のインストールと設定を自動化できます。

### 前提条件

- `make setup` が完了し、`.env` が存在すること
- 以下の変数を `.env` に追記すること:

```shell
# .env (Ansible 用の追加項目)
CF_TUNNEL_TOKEN=your-cloudflare-tunnel-token
SUDO_PASS=your-sudo-password
```

### 実行

```shell
make setup-ansible
```

ドライラン（変更を適用しない確認用）:

```shell
make setup-ansible ARGS="--check --diff"
```

### Ansible Vault（オプション）

`CF_TUNNEL_TOKEN` を `.env` に書く代わりに、Ansible Vault で管理することもできます。

```shell
# サンプルからコピーし、暗号化済み Vault ファイルを作成する
cp ansible/vault/secrets.yml.example ansible/vault/secrets.yml
ansible-vault create ansible/vault/secrets.yml
```

Vault 認証付きで実行:

```shell
make setup-ansible ARGS="--ask-vault-pass"
# または
make setup-ansible ARGS="--vault-password-file /path/to/.vault_pass"
```

> `.env` と Vault の両方に `CF_TUNNEL_TOKEN` が設定されている場合、`.env` の値が優先されます。
