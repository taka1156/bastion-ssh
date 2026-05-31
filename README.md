# bastion-ssh

[日本語版はこちら](README.ja.md)

A portable SSH bastion tool using Dev Containers. Connect to any remote server without touching your local host environment. Also works with GitHub Codespaces.

> **Dev Container ready**  
> This repository uses [Dev Containers](https://containers.dev/).  
> Open it in VS Code with the Dev Containers extension and run all local commands from inside the container.

## Setup

### 1. Configure connection settings

Generate `tool/.env` interactively.

```shell
make setup
```

The generated `.env` looks like:

```shell
# tool/.env
HOST=xxx.xxx.xxx.xxx
USER={user}
PORT=9999
KEY=/root/.ssh/your-key.pem
```

> If you get a permission error for the private key, run:
> ```shell
> chmod 600 /root/.ssh/your-key.pem
> ```

### 2. Connect via SSH

```shell
make ssh
```

## File transfer

### rsync

```shell
# Upload
make rsync ARGS="-av ./local/path/ {user}@{host}:/remote/path/"

# Download
make rsync ARGS="-av {user}@{host}:/remote/path/ ./local/path/"
```

### SFTP

```shell
make sftp ARGS="{user}@{host}"
```

## Optional: Cloudflare Tunnel

Using Cloudflare Tunnel, you can connect to the VPS without exposing the SSH port directly to the internet.

### Prerequisites

- A Cloudflare Zero Trust tunnel has been created
- The SSH hostname is registered as a Public Hostname on the tunnel
- `cloudflared` is installed inside the Dev Container

### Configuration

When running `make setup`, select yes to enable Cloudflare Tunnel. The following variables will be added to `tool/.env`.

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

With `ENABLE_TUNNEL=true`, all commands (`make ssh`, `make rsync`, `make sftp`) automatically route through Cloudflare Tunnel.
