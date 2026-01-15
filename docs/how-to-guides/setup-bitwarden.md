---
sidebar_position: 7
title: Configure Bitwarden Secrets Manager
---

# Configure Bitwarden Secrets Manager

Bitwarden Secrets Manager stores bootstrap and runtime secrets for the cluster.

## Create the bootstrap token

1. Log in to Bitwarden Secrets Manager.
2. Create a machine access token with access to the secrets used for bootstrap.
3. Add the token to your `.env` as `BWS_ACCESS_TOKEN`.

See [Environment Variables](../reference/environment-variables) for where it is used.

## Store the runtime token

The cluster uses a second token for runtime sync. Store it in Bitwarden so Terragrunt can fetch it during bootstrap:

- Secret name: `BWS_ACCESS_TOKEN`
- Project: `kubernetes`

The flow is documented in [Bitwarden Access Tokens](../explanation/bitwarden-access-tokens).

## Apply bootstrap secrets

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task k8s:bootstrap-secrets"
```

## Troubleshooting

If secrets are not syncing, see [Troubleshooting](troubleshooting).
