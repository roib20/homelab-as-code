---
sidebar_position: 6
title: Security Model
---

# Security Model

Security is layered across the stack to reduce exposure and keep secrets centralized.

## OS and infrastructure

- Talos is immutable and API-driven to reduce drift.
- Proxmox access is restricted to trusted networks.

## Cluster access

- Tailscale provides authenticated admin access.
- Cloudflare tunnels expose services without inbound ports.

## Secrets

- Bitwarden Secrets Manager stores bootstrap and runtime secrets.
- External Secrets keeps workloads synchronized with Bitwarden.

## Related docs

- [Secrets Management](secrets-management)
- [Networking Architecture](networking-architecture)
