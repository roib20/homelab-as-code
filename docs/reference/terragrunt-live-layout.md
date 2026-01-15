---
sidebar_position: 13
title: Terragrunt Live Layout
---

# Terragrunt Live Layout

The `terragrunt/infrastructure-live/` directory defines environments and stacks that consume catalog units.

## Top-level layout

```text
terragrunt/infrastructure-live/
├── _envcommon/          # Shared inputs and providers
├── root.hcl             # Backend and global inputs
├── prod/                # Production environment
└── non-prod/            # Non-production environment
```

## Environment layout

```text
prod/
├── account.hcl.example  # Account-wide variables (copy to account.hcl)
├── multi-node/          # Talos cluster stacks
├── pve-node-01/         # Per-node settings
├── pve-node-02/
└── pve-node-03/
```

## Key files

- `root.hcl` configures the remote state backend and merges account/node inputs.
- `_envcommon/common.hcl` defines shared inputs such as DNS and time servers.
- `_envcommon/proxmox-provider.hcl` generates the Proxmox provider configuration.

## Related docs

- [Terragrunt Units and Modules](terragrunt-units)
- [Talos Stack Configuration](talos-stack-config)
- [Account and Node Configuration](terragrunt-account-config)
