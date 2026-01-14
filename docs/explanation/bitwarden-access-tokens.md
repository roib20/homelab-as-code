# Bitwarden Access Tokens

This homelab uses a two-token bootstrapping process for Bitwarden Secrets Manager integration.

## Token Architecture

### First "BWS_ACCESS_TOKEN" (Bootstrap Token)

- **Location**: Stored in `.env` file as "BWS_ACCESS_TOKEN"
- **Purpose**: Used by Terragrunt to authenticate with Bitwarden during bootstrap
- **Scope**: Retrieves secrets from Bitwarden Secrets Manager for initial cluster setup

### Second "BWS_ACCESS_TOKEN" (Runtime Token)

- **Location**: Stored inside Bitwarden Secrets Manager as "BWS_ACCESS_TOKEN" under "kubernetes" project
- **Purpose**: Used by external-secrets-operator for ongoing secret synchronization
- **Flow**: Retrieved by Terragrunt → Applied as `bitwarden-access-token` Kubernetes secret

## Bootstrap Process

1. Terragrunt reads first token from `.env`
2. Authenticates with Bitwarden Secrets Manager
3. Retrieves second token from Bitwarden
4. Applies second token as `bitwarden-access-token` secret in `bitwarden` namespace
5. External-secrets operator uses second token for secret synchronization

## Troubleshooting

### SecretSyncedError in ExternalSecrets

This usually indicates the second token (runtime token) is invalid or expired.

**Solution:**

1. Update both tokens in their respective locations
2. Restart the container to clear cached environment variables
3. Re-run bootstrap:

   **Option A - Terragrunt directly:**

   ```shell
   cd terragrunt/infrastructure-live/prod/multi-node/bootstrap-k8s-secrets
   terragrunt stack run apply
   ```

   **Option B - Ansible (if configured):**
   The `bitwarden_secretsmanager` role exists but is not currently included in `k8s-playbook.yml`

### Common Issues

- Expired tokens
- Wrong token format
- Missing organization access
- Container not restarted after token update
