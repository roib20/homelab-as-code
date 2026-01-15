---
sidebar_position: 14
title: Manage Cloudflare Tunnels
---

# Manage Cloudflare Tunnels

Cloudflare tunnels are managed by the cloudflare-operator addon.

## Check tunnel resources

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:list"
```

## Check operator status

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:status"
```

## Related docs

- [Configure Cloudflare Integration](setup-cloudflare)
- [Ingress Controllers](../reference/ingress-controllers)
- [Troubleshooting](troubleshooting)
