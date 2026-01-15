---
sidebar_position: 2
title: Configure Environment Variables
---

# Configure Environment Variables

The runner container reads secrets from `.env`. Start from `env.example` and populate the required tokens.

## Create the `.env` file

```shell
cp env.example .env
```

## Required values

- `BWS_ACCESS_TOKEN` from Bitwarden Secrets Manager
- `CLOUDFLARE_API_TOKEN` for R2 bootstrap
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for R2 access

See [Environment Variables](../reference/environment-variables) for details.

## Validate

Run a quick info command inside the runner to confirm the file is loading:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "env | grep -E 'BWS_ACCESS_TOKEN|CLOUDFLARE_API_TOKEN|AWS_ACCESS_KEY_ID'"
```
