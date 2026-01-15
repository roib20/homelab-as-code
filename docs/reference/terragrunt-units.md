---
sidebar_position: 6
title: Terragrunt Units and Modules
---

# Terragrunt Units and Modules

Terragrunt configuration lives under `terragrunt/` and is split into reusable units and catalog modules.

## Catalog units

Units in `terragrunt/infrastructure-catalog/units/` include:

- `bitwarden-secrets-manager`
- `bootstrap-k8s-secrets`
- `cloud-config`
- `cloud-controller-manager`
- `cloud-init-vm`
- `proxmox_virtual_environment_download_file`
- `proxmox_virtual_environment_vm`
- `qemu-guest-agent`
- `secureboot-vm`
- `talos-cluster`
- `talos-vm`
- `truenas`

## Catalog modules

- `modules/cluster/resources/modules/talos-cluster`

Refer to the module README for full inputs/outputs and upgrade behavior.

## Related docs

- [Terragrunt Live Layout](terragrunt-live-layout)
- [Talos Stack Configuration](talos-stack-config)
- [Layer 3: Terragrunt with OpenTofu](../tutorials/Layers/Layer%203)
- [Layer 4: Taskfile (Talos Cluster)](../tutorials/Layers/Layer%204)
