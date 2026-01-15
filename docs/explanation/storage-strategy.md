---
sidebar_position: 5
title: Storage Strategy
---

# Storage Strategy

Storage is split between VM-level management (TrueNAS) and Kubernetes storage classes provided by addons.

## TrueNAS layer

- TrueNAS is provisioned as a VM during Layer 3.
- It manages storage pools and datasets for the homelab.

## Kubernetes storage

- `hostpath-provisioner` provides local storage for workloads that can use node-local disks.
- Stateful operators like `cloudnative-pg` manage their own persistent data through Kubernetes volumes.

## Operational notes

- Confirm storage pools are healthy in TrueNAS before deploying stateful apps.
- Review addon configuration under `kubernetes/cluster/active/addons/`.

## Related docs

- [Layer 3: Terragrunt with OpenTofu](../tutorials/Layers/Layer%203)
- [Kubernetes Addons](../reference/kubernetes-addons)
