# ssh-bastion

[English version here](README.md)

Dev Container を使った汎用 SSH 踏み台ツールです。ローカル環境を汚さずにリモートサーバーへ接続できます。GitHub Codespaces からも利用可能です。

> **Dev Container 対応**  
> このリポジトリは [Dev Containers](https://containers.dev/) を使用しています。  
> VS Code + Dev Containers 拡張機能でコンテナを起動し、その中から操作してください。

## セットアップ

### 1. リモートサーバー側

> 管理者は、GMOインターネットグループ株式会社が運営している [ConoHa VPS](https://vps.conoha.jp/) を利用しています。

ユーザーを作成し、SSH 公開鍵を配置します。`{user}` は任意のユーザー名に置き換えてください。

```shell
adduser {user}
usermod -aG sudo {user}

mkdir -p /home/{user}/.ssh
cp /root/.ssh/authorized_keys /home/{user}/.ssh/
chown -R {user}:{user} /home/{user}/.ssh
chmod 700 /home/{user}/.ssh
chmod 600 /home/{user}/.ssh/authorized_keys
```

設定後の確認:

```shell
ls -la /home/{user}/.ssh/
# total 12
# drwx------ 2 {user} {user} 4096 May 29 08:15 .
# drwxr-x--- 3 {user} {user} 4096 May 29 08:05 ..
# -rw------- 1 {user} {user}  399 May 29 08:54 authorized_keys
```

### 2. ローカル側（Dev Container 内で実行）

```shell
chmod +x tool/ssh.sh
chmod 600 /root/.ssh/your-key.pem
```

## SSH 接続

`tool/.env.example` を `tool/.env` にコピーして接続情報を設定します。

```shell
cp tool/.env.example tool/.env
```

```shell
# tool/.env
SSH_HOST=xxx.xxx.xxx.xxx
SSH_USER={user}
SSH_PORT=9999
SSH_KEY=/root/.ssh/your-key.pem
```

接続:

```shell
./tool/ssh.sh
```
