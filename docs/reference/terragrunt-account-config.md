---
sidebar_position: 14
title: Account and Node Configuration
---

# Account and Node Configuration

Terragrunt uses `account.hcl` and node configuration files to inject environment-specific values.

## Account configuration

- Copy `account.hcl.example` to `account.hcl` under each environment directory.
- Values are read by `root.hcl` and merged into all stack inputs.

Key sections include:

- `proxmox`: API endpoint and credentials
- `cloudflare`: R2 account, endpoint, and bucket name
- `tailscale`: auth key for provisioning

## Node configuration

- `nodes.hcl` defines multiple Proxmox nodes for multi-node clusters.
- `node.hcl` defines single-node settings used by some stacks.

## Related docs

- [Terragrunt Live Layout](terragrunt-live-layout)
- [Talos Stack Configuration](talos-stack-config)
