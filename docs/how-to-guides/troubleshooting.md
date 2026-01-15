---
sidebar_position: 5
title: Troubleshooting
---

# Troubleshooting

Use this guide to diagnose common issues during provisioning or day-to-day operations.

## Quick health checks

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:status"
```

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:info"
```

## GitOps and Argo CD

- If applications are not syncing, check Argo CD access via [Access Argo CD](access-argocd).
- Confirm the ApplicationSet `config.json` paths in [Add a New Application](add-application).

## Layer-specific checks

### Layer 1 (Debian preseed)

- Ensure the preseed URL is reachable from the installer.
- Verify UEFI boot mode and Secure Boot status.
- Confirm the target disk name matches the preseed config.

### Layer 2 (Proxmox with Ansible)

- Validate SSH connectivity to each node (`ssh <node-ip>`).
- Confirm the Tailscale auth key is reusable and pre-approved.
- Check inventory alignment with actual node IPs.

### Layer 3 (Terragrunt/TrueNAS)

- Confirm R2 credentials are set in `.env`.
- Validate that the R2 bucket exists and remote state config is correct.
- Ensure the Proxmox VM templates are accessible to Terragrunt.

### Layer 4 (Talos cluster)

- Re-run `task talos:plan` to inspect drift.
- Validate Bitwarden tokens in `.env` and secrets manager.
- Check Argo CD sync status after bootstrap.

## Logs and diagnostics

- Use `kubectl get pods -A` and `kubectl describe` for failing workloads.
- Use `talosctl health` and `talosctl dashboard` for node-level inspection.
- Re-run the corresponding task with `--dry-run` where available.

## Related guides

- [Update Talos Linux](update-talos)
- [Destroy the Cluster](destroy-cluster)
- [Configure Bitwarden Secrets Manager](setup-bitwarden)
- [Manage Certificates](manage-certificates)
- [Manage Cloudflare Tunnels](cloudflare-tunnels)
- [Scale the Cluster](scale-cluster)
- [Bitwarden Access Tokens](../explanation/bitwarden-access-tokens)
