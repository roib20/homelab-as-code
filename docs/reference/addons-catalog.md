---
sidebar_position: 12
title: Addons Catalog
---

# Addons Catalog

Addons are managed under `kubernetes/cluster/active/addons/` and deployed by Argo CD.

## Addons

| Addon | Category | Path |
| --- | --- | --- |
| `cilium` | Networking | `kubernetes/cluster/active/addons/cilium` |
| `coredns` | Networking | `kubernetes/cluster/active/addons/coredns` |
| `cert-manager` | Certificates | `kubernetes/cluster/active/addons/cert-manager` |
| `external-secrets` | Secrets | `kubernetes/cluster/active/addons/external-secrets` |
| `cloudflare-operator` | Ingress | `kubernetes/cluster/active/addons/cloudflare-operator` |
| `istio-base` | Service mesh | `kubernetes/cluster/active/addons/istio/istio-base` |
| `istio-istiod` | Service mesh | `kubernetes/cluster/active/addons/istio/istio-istiod` |
| `anubis` | Security | `kubernetes/cluster/active/addons/anubis` |
| `hostpath-provisioner` | Storage | `kubernetes/cluster/active/addons/hostpath-provisioner` |
| `cloudnative-pg` | Data | `kubernetes/cluster/active/addons/cloudnative-pg` |
| `valkey-operator` | Data | `kubernetes/cluster/active/addons/valkey-operator` |
| `reloader` | Utilities | `kubernetes/cluster/active/addons/reloader` |
| `reflector` | Utilities | `kubernetes/cluster/active/addons/reflector` |
| `spegel` | Utilities | `kubernetes/cluster/active/addons/spegel` |
| `talos-cloud-controller-manager` | Core | `kubernetes/cluster/active/addons/talos-cloud-controller-manager` |
| `node-feature-discovery` | Core | `kubernetes/cluster/active/addons/node-feature-discovery` |
| `intel-gpu-resource-driver` | Hardware | `kubernetes/cluster/active/addons/intel-gpu-resource-driver` |
| `kaniop` | Identity | `kubernetes/cluster/active/addons/kaniop` |

## Related docs

- [Kubernetes Addons](kubernetes-addons)
- [GitOps Workflow](../explanation/gitops-workflow)
