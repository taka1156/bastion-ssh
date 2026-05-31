# bastion-ssh

[English version here](README.md)

Dev Container を使った汎用 SSH 踏み台ツールです。ローカル環境を汚さずにリモートサーバーへ接続できます。GitHub Codespaces からも利用可能です。

> **Dev Container 対応**  
> このリポジトリは [Dev Containers](https://containers.dev/) を使用しています。  
> VS Code + Dev Containers 拡張機能でコンテナを起動し、その中から操作してください。

## セットアップ

### 1. 接続情報の設定

対話形式で `tool/.env` を生成します。

```shell
make setup
```

生成される `.env` の内容:

```shell
# tool/.env
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
# tool/.env
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
