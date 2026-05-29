# bastion-ssh

[日本語版はこちら](README.ja.md)

A portable SSH bastion tool using Dev Containers. Connect to any remote server without touching your local host environment. Also works with GitHub Codespaces.

> **Dev Container ready**  
> This repository uses [Dev Containers](https://containers.dev/).  
> Open it in VS Code with the Dev Containers extension and run all local commands from inside the container.

## Setup

### 1. Remote server

> The administrator uses [ConoHa VPS](https://vps.conoha.jp/) operated by GMO Internet Group.

Create a user and place the SSH public key. Replace `{user}` with your desired username.

```shell
adduser {user}
usermod -aG sudo {user}

mkdir -p /home/{user}/.ssh
cp /root/.ssh/authorized_keys /home/{user}/.ssh/
chown -R {user}:{user} /home/{user}/.ssh
chmod 700 /home/{user}/.ssh
chmod 600 /home/{user}/.ssh/authorized_keys
```

Verify:

```shell
ls -la /home/{user}/.ssh/
# total 12
# drwx------ 2 {user} {user} 4096 May 29 08:15 .
# drwxr-x--- 3 {user} {user} 4096 May 29 08:05 ..
# -rw------- 1 {user} {user}  399 May 29 08:54 authorized_keys
```

### 2. Local (inside Dev Container)

```shell
chmod +x tool/ssh.sh
chmod 600 /root/.ssh/your-key.pem
```

## SSH connection

Copy `tool/.env.example` to `tool/.env` and fill in your connection details.

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

Connect:

```shell
./tool/ssh.sh
```

## SSH connection via Cloudflare Tunnel

Using Cloudflare Tunnel, you can connect to the VPS without exposing the SSH port directly to the internet.

### Prerequisites

- A Cloudflare Zero Trust tunnel has been created
- The SSH hostname is registered as a Public Hostname on the tunnel
- `cloudflared` is installed inside the Dev Container

### Configuration

Add the Cloudflare Tunnel variables to `tool/.env`.

```shell
# tool/.env
SSH_HOST=xxx.xxx.xxx.xxx
SSH_USER={user}
SSH_PORT=22
SSH_KEY=/root/.ssh/your-key.pem

# Cloudflare Tunnel
SUBDOMAIN=subdomain
DOMAIN=example.com
```

Connect:

```shell
chmod +x tool/cloudflared.sh
./tool/cloudflared.sh
```

This uses `SUBDOMAIN.DOMAIN` as the ProxyCommand hostname to establish an SSH tunnel through cloudflared.
