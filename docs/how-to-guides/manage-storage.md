---
sidebar_position: 12
title: Manage Storage
---

# Manage Storage

Storage configuration is split between TrueNAS and Kubernetes storage classes.

## Verify TrueNAS

- Confirm pools and datasets are healthy.
- Validate SMB/NFS shares if used by workloads.

## Inspect Kubernetes storage

```shell
kubectl get storageclass
kubectl get pvc -A
```

## Related docs

- [Storage Strategy](../explanation/storage-strategy)
- [Layer 3: Terragrunt with OpenTofu](../tutorials/Layers/Layer%203)
- [Troubleshooting](troubleshooting)
