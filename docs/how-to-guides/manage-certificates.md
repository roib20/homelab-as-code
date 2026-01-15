---
sidebar_position: 13
title: Manage Certificates
---

# Manage Certificates

Certificates are managed by cert-manager and the related cluster resources in `kubernetes/cluster/active/resources/`.

## Check cert-manager status

```shell
kubectl get pods -n cert-manager
```

## Inspect cluster issuers

```shell
kubectl get clusterissuers
```

## Validate certificates

```shell
kubectl get certificates -A
```

## Related docs

- [Kubernetes Addons](../reference/kubernetes-addons)
- [Networking Architecture](../explanation/networking-architecture)
- [Troubleshooting](troubleshooting)
