---
sidebar_position: 11
title: Cluster Resources
---

# Cluster Resources

Cluster-wide resources live under `kubernetes/cluster/active/resources/` and are applied via Argo CD.

## Resource groups

| Resource | Purpose | Path |
| --- | --- | --- |
| `cert-resources` | Cluster issuers and certificates | `kubernetes/cluster/active/resources/cert-resources` |
| `cloudflare-resources` | Tunnel bindings and DNS resources | `kubernetes/cluster/active/resources/cloudflare-resources` |
| `istio-resources` | Istio gateways and routing rules | `kubernetes/cluster/active/resources/istio-resources` |

## Related docs

- [Manage Certificates](../how-to-guides/manage-certificates)
- [Manage Cloudflare Tunnels](../how-to-guides/cloudflare-tunnels)
- [Ingress Controllers](ingress-controllers)
