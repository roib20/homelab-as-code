---
sidebar_position: 2
title: GitOps Workflow
---

# GitOps Workflow

The cluster is driven by GitOps: changes land in Git, Argo CD reconciles them into the cluster, and ApplicationSets manage app discovery.

## Source of truth

- Git is the single source of truth for cluster configuration.
- Argo CD watches the repository and continuously reconciles changes.
- ApplicationSets scan for `config.json` files and create Applications automatically.

## Application discovery

ApplicationSets look for configurations in these paths:

- `kubernetes/cluster/active/addons/**/overlays/*/config.json`
- `kubernetes/cluster/active/apps/**/overlays/*/config.json`
- `kubernetes/cluster/active/resources/**/overlays/*/config.json`
- `kubernetes/cluster/active/ingress-controllers/**/overlays/*/config.json`

See [ApplicationSet Config Format](../reference/applicationset-config) for required fields.

## Typical workflow

1. Create or update manifests under `kubernetes/cluster/active/`.
2. Commit and push changes to the repository.
3. Argo CD detects the change and applies it to the cluster.

## Verification

- Check application status in Argo CD.
- Use `task cluster:status` to review cluster health.

## Related guides

- [Add a New Application](../how-to-guides/add-application)
- [Access Argo CD](../how-to-guides/access-argocd)
