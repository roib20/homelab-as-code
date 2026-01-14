# Environment Variables

Environment variables are defined in `.env` (created from `env.example`).

## Required variables

### BWS_ACCESS_TOKEN

Bitwarden Secrets Manager access token for bootstrapping.

```shell
BWS_ACCESS_TOKEN=""
```

This token authenticates Terragrunt with Bitwarden during initial cluster setup. See [Bitwarden Access Tokens](../explanation/bitwarden-access-tokens.md) for the two-token architecture.

### CLOUDFLARE_API_TOKEN

Cloudflare API token for bootstrapping R2 bucket creation.

```shell
CLOUDFLARE_API_TOKEN=""
```

This token is used during initial setup to create the R2 bucket via `tofu/bootstrap-r2-bucket/init.sh`. After bootstrap, the cloudflare-operator retrieves its own token from Bitwarden Secrets Manager for ongoing tunnel and DNS management.

### AWS_ACCESS_KEY_ID

R2 API token access key ID for S3-compatible access to Cloudflare R2.

```shell
AWS_ACCESS_KEY_ID=""
```

Created after the R2 bucket is set up. Used by Terragrunt for remote state storage. Despite the name, these are Cloudflare R2 credentials, not AWS credentials.

### AWS_SECRET_ACCESS_KEY

R2 API token secret key.

```shell
AWS_SECRET_ACCESS_KEY=""
```

Created after the R2 bucket is set up. Used by Terragrunt for remote state storage.

## Creating the .env file

Copy the example file:

```shell
cp env.example .env
```

Fill in the values and ensure the file is not committed to version control (`.env` is in `.gitignore`).

## Usage with Docker Compose

The `compose.yaml` passes these variables to the runner container:

```yaml
environment:
  - BWS_ACCESS_TOKEN
  - CLOUDFLARE_API_TOKEN
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
```

When using the runner container, the variables are automatically available.
