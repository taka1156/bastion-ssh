---
name: bastion-ssh
description: 'Overview and usage guide for the bastion-ssh project — a portable SSH bastion tool built on Dev Containers. Use when asking about project purpose, setup steps, available make commands, file transfer methods, or Cloudflare Tunnel integration.'
---

# bastion-ssh

A portable SSH bastion tool powered by Dev Containers. Connect to any remote server without modifying your local host environment. Also compatible with GitHub Codespaces.

## Purpose

Isolate SSH credentials and connection logic inside a Dev Container so that:
- No SSH keys or config files are written to the host machine.
- The same workflow runs identically on any machine that supports Dev Containers or Codespaces.

## Repository Structure

```
.devcontainer/       # Dev Container configuration
tool/
  setup_env.sh       # Interactive .env generator
  ssh.sh             # SSH connection wrapper
  rsync.sh           # rsync wrapper with tunnel support
  sftp.sh            # SFTP wrapper with tunnel support
  .env.example       # Template for connection variables
Makefile             # User-facing commands
```

## Configuration

Run the interactive setup to generate `tool/.env`:

```shell
make setup
# Optional: write to a specific path
make setup ARGS=path/to/.env
```

The generated `tool/.env` contains:

| Variable       | Description                          |
|----------------|--------------------------------------|
| `HOST`     | Remote server IP address             |
| `USER`     | SSH login username                   |
| `PORT`     | SSH port (default: 22)               |
| `KEY`      | Path to the private key inside the container |
| `ENABLE_TUNNEL`| `true` to route through Cloudflare Tunnel |
| `SUBDOMAIN`    | Cloudflare Tunnel subdomain (tunnel only) |
| `DOMAIN`       | Cloudflare Tunnel domain (tunnel only) |

> If you get a permission error for the private key, run:
> ```shell
> chmod 600 /root/.ssh/your-key.pem
> ```

## Available Commands

| Command | Description |
|---------|-------------|
| `make setup` | Generate `tool/.env` interactively |
| `make ssh` | Open an SSH session to the remote host |
| `make rsync ARGS="..."` | Transfer files via rsync |
| `make sftp ARGS="..."` | Open an interactive SFTP session |

### rsync examples

```shell
# Upload
make rsync ARGS="-av ./local/path/ user@host:/remote/path/"

# Download
make rsync ARGS="-av user@host:/remote/path/ ./local/path/"
```

## Cloudflare Tunnel (Optional)

When `ENABLE_TUNNEL=true`, all commands (`make ssh`, `make rsync`, `make sftp`) automatically route through Cloudflare Tunnel using `cloudflared access ssh` as a ProxyCommand. This avoids exposing the SSH port directly to the internet.

### Prerequisites

1. A Cloudflare Zero Trust tunnel has been created.
2. The SSH hostname is registered as a Public Hostname on that tunnel.
3. `cloudflared` is installed inside the Dev Container.

### How it works

- **Without tunnel**: `ssh -i $KEY -p $PORT $USER@$HOST`
- **With tunnel**: `ssh -i $KEY -p $PORT -o ProxyCommand="cloudflared access ssh --hostname $SUBDOMAIN.$DOMAIN" $USER@$HOST`
