---
sidebar_position: 8
title: Configure Cloudflare Integration
---

# Configure Cloudflare Integration

Cloudflare is used for R2 remote state and for tunnel-based ingress via cloudflare-operator.

## Bootstrap R2

Follow [Bootstrap the R2 Bucket](bootstrap-r2) to create the bucket and access credentials.

## Provide API tokens

Add the following to `.env`:

- `CLOUDFLARE_API_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

See [Environment Variables](../reference/environment-variables) for details.

## Inspect Cloudflare resources

Once the cluster is running:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:status"
```

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:list"
```

## Related guides

- [Manage Cloudflare Tunnels](cloudflare-tunnels)
- [Destroy the Cluster](destroy-cluster)
- [Troubleshooting](troubleshooting)
