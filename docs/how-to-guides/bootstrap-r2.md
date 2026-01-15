---
sidebar_position: 4
title: Bootstrap the R2 Bucket
---

# Bootstrap the R2 Bucket

Terragrunt remote state uses Cloudflare R2. Bootstrap the bucket before running Layer 3 or Layer 4.

## Prerequisites

- `CLOUDFLARE_API_TOKEN` in your `.env`
- Cloudflare account ID
- Docker runner built (recommended)

## Run the bootstrap script

```shell
cd tofu/bootstrap-r2-bucket
./init.sh
```

The script guides you through:

- Validating the Cloudflare API token
- Creating the R2 bucket
- Generating R2 access credentials
- Writing the backend configuration

## Persist credentials

Copy the generated R2 access key ID and secret into `.env`:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Next steps

- [Configure environment variables](configure-env)
- [Layer 3: Terragrunt with OpenTofu](../tutorials/Layers/Layer%203)
