---
sidebar_position: 8
title: Ingress Controllers
---

# Ingress Controllers

Ingress controllers live under `kubernetes/cluster/active/ingress-controllers/`.

## Available controllers

| Controller | Purpose | Path |
| --- | --- | --- |
| `istio-gateway` | Istio ingress gateway | `kubernetes/cluster/active/ingress-controllers/istio/istio-gateway` |
| `tailscale-operator` | Tailscale-based ingress | `kubernetes/cluster/active/ingress-controllers/tailscale-operator` |

## Related docs

- [Networking Architecture](../explanation/networking-architecture)
- [Kubernetes Addons](kubernetes-addons)
