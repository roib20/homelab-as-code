---
sidebar_position: 3
title: Networking Architecture
---

# Networking Architecture

Networking combines in-cluster routing with secure edge access so services can be exposed safely.

## Core components

- **Cilium** provides the Kubernetes CNI and network policy enforcement.
- **Istio** handles ingress routing and service mesh capabilities.
- **Cloudflare tunnels** expose services without opening inbound ports.
- **Tailscale** enables secure admin access during provisioning.

## Traffic flow

```mermaid
flowchart LR
  Client[Client] --> Cloudflare[Cloudflare Tunnel]
  Cloudflare --> Istio[Istio Gateway]
  Istio --> Service[Kubernetes Service]
  Service --> Pod[Pod]
```

## Related references

- [Kubernetes Addons](../reference/kubernetes-addons)
- [Addons Catalog](../reference/addons-catalog)
- [Ingress Controllers](../reference/ingress-controllers)
- [Network Reference](../reference/network-architecture)
- [Architecture Overview](architecture-overview)
