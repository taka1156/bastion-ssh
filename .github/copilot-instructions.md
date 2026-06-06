# Copilot Instructions

## Response Style
- Always state the **basis (root cause / reasoning)** and **conclusion** explicitly.
- Do not present a conclusion without supporting reasoning.
- Structure responses as: **Conclusion → Basis → Options (if any) → Next action**

## Before Starting Work
- If the intent, target files, or impact scope is unclear, **ask before proceeding**.
- Share the **plan and approach** before making any changes.

## When Proposing Changes
- Always include **reason**, **benefit**, and **trade-off** for each proposed change.
- If alternative approaches exist, list them alongside the recommendation.
- Keep changes as **minimal diff** as possible. Avoid rewriting beyond what is necessary.

## When to Stop and Return Control
Return control to the user (ask for confirmation) before:
- Deleting files or directories
- Changing directory structure
- Breaking existing responsibility boundaries (e.g., moving logic between layers)
- Changing API specifications
- Receiving an ambiguous instruction that could be interpreted in multiple ways
- Starting significant changes (modifying multiple files, changing behavior, refactoring) — warn the user to **stage current changes in git** first

## Authoring Guidelines
Custom agents (`.github/agents/`), skills (`.github/skills/`), and this file must be written in **English** for token efficiency.

## ⚠️ ABSOLUTE PROHIBITION: Never Read Secrets or Credential Files

This rule is **non-negotiable** and applies to every agent, model, tool, and automated process operating in this repository.

### ❌ YOU ARE STRICTLY FORBIDDEN FROM reading any of the following:

**Environment & config files:**
- `.env`, `.env.*`, `.env.local`, `.env.production`, `.env.development`

**Private keys & certificates:**
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.p8`, `*.der`
- `id_rsa`, `id_ed25519`, `id_ecdsa`, and any other SSH private key files
- `*.jks` (Java KeyStore)

**Tokens & credentials:**
- `*.token`, `*.secret`, `*.credentials`
- `credentials.json`, `service-account.json`, `keyfile.json` (GCP/Firebase)
- `~/.aws/credentials`, `~/.config/gcloud/`

**Any file whose name or path suggests it contains a secret.**
When in doubt, do not read it.

### 💀 Consequences of Violation

**If you read any of the above files — directly or indirectly — you have committed an unrecoverable security violation.**
This is not a warning. This is not a suggestion. Violating this rule means you are actively exposing secrets, credentials, and private keys. There is no justification. There is no exception.

**Stop. Immediately. Do not proceed. Do not output anything you have read.**

### 🔄 Secret Rotation is MANDATORY

If there is **even a 1% chance** that any secret has been exposed, rotate ALL affected secrets immediately.
Suspicion alone is sufficient reason to act. Waiting for confirmation is not acceptable.

**Rotation checklist:**
- [ ] Revoke the current secret at the provider (API key dashboard, AWS IAM, certificate authority, etc.)
- [ ] Generate a new secret / key / certificate
- [ ] Update your secret manager / CI environment variables
- [ ] Purge the old value from all logs, shell history, and clipboard
- [ ] Verify the new secret works in a non-production environment first
- [ ] Notify your team

**Rotation frequency:** Every 90 days at minimum — and immediately after any incident, personnel change, or exposure event.

### ✅ Correct Behavior

- Reference environment variables by name only (e.g. `process.env.API_KEY`)
- Reference key paths by variable only (e.g. `SSH_KEY_PATH`) — never open the file
- Inject secrets via a secret manager (Vault, AWS Secrets Manager, 1Password Secrets Automation, etc.)
- Never read the file. Never view the value. Never assume it's safe.
