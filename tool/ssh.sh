#!/bin/bash

source "$(dirname "$0")/.env"

ssh -i "$SSH_KEY" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST"
