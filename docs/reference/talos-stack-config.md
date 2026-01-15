---
sidebar_position: 15
title: Talos Stack Configuration
---

# Talos Stack Configuration

The Talos cluster stack is defined in `terragrunt/infrastructure-live/<env>/multi-node/talos-cluster/terragrunt.stack.hcl`.

## Key sections

- **Versions**: controls Talos and Kubernetes versions.
- **Nodes**: control plane and worker node definitions.
- **Networking**: cluster VIP, pod, and service CIDRs.
- **Helm charts**: bootstrap charts applied during cluster creation.

## Version notes

- `initial_talos_version` should not change after first deployment.
- `talos_version` controls upgrades.

## Node definitions

Each node includes:

- `name`, `ip`, `vm_id`, `cpu_cores`, `memory`
- `node_name` for the Proxmox host
- `install` settings (disk, secure boot, extensions)

## Related docs

- [Terragrunt Live Layout](terragrunt-live-layout)
- [Terragrunt Units and Modules](terragrunt-units)
- [Update Talos Linux](../how-to-guides/update-talos)
- [Scale the Cluster](../how-to-guides/scale-cluster)
