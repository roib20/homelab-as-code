# Kubernetes Addons

Active addons deployed via Argo CD from `kubernetes/cluster/active/addons/`.

## Networking

### cilium

CNI plugin providing networking, network policy enforcement, and load balancing.

- Path: `kubernetes/cluster/active/addons/cilium/`
- Namespace: `kube-system`

### coredns

DNS server for Kubernetes service discovery.

- Path: `kubernetes/cluster/active/addons/coredns/`
- Namespace: `kube-system`

## Security and certificates

### cert-manager

Automated TLS certificate management with Let's Encrypt integration.

- Path: `kubernetes/cluster/active/addons/cert-manager/`
- Namespace: `cert-manager`

### external-secrets

Operator that synchronizes secrets from Bitwarden Secrets Manager into Kubernetes.

- Path: `kubernetes/cluster/active/addons/external-secrets/`
- Namespace: `external-secrets`

### kaniop

Kanidm operator for identity and access management.

- Path: `kubernetes/cluster/active/addons/kaniop/`
- Namespace: `kanidm`

## Ingress and tunneling

### cloudflare-operator

Manages Cloudflare Tunnels and DNS records for external access.

- Path: `kubernetes/cluster/active/addons/cloudflare-operator/`
- Namespace: `cloudflare-operator`

### anubis

Proof-of-work challenge system for protecting services from bots.

- Path: `kubernetes/cluster/active/addons/anubis/`
- Namespace: `anubis`

## Storage

### hostpath-provisioner

Provides local storage using host paths.

- Path: `kubernetes/cluster/active/addons/hostpath-provisioner/`
- Namespace: `hostpath-provisioner`

## Operators and utilities

### cloudnative-pg

PostgreSQL operator for managing PostgreSQL clusters.

- Path: `kubernetes/cluster/active/addons/cloudnative-pg/`
- Namespace: `cnpg-system`

### valkey-operator

Operator for managing Valkey (Redis-compatible) clusters.

- Path: `kubernetes/cluster/active/addons/valkey-operator/`
- Namespace: `valkey-operator`

### reloader

Watches ConfigMaps and Secrets, triggering rolling updates when they change.

- Path: `kubernetes/cluster/active/addons/reloader/`
- Namespace: `reloader`

### reflector

Mirrors Secrets and ConfigMaps across namespaces.

- Path: `kubernetes/cluster/active/addons/reflector/`
- Namespace: `reflector`

### spegel

Peer-to-peer container image distribution within the cluster.

- Path: `kubernetes/cluster/active/addons/spegel/`
- Namespace: `spegel`

### talos-cloud-controller-manager

Cloud controller manager for Talos Linux integration.

- Path: `kubernetes/cluster/active/addons/talos-cloud-controller-manager/`
- Namespace: `kube-system`

### node-feature-discovery

Detects hardware features on nodes and labels them accordingly.

- Path: `kubernetes/cluster/active/addons/node-feature-discovery/`
- Namespace: `node-feature-discovery`

### intel-gpu-resource-driver

GPU resource driver for Intel integrated graphics.

- Path: `kubernetes/cluster/active/addons/intel-gpu-resource-driver/`
- Namespace: `intel-gpu-resource-driver`

## Resources

Cluster-wide resources in `kubernetes/cluster/active/resources/`:

| Resource | Description |
|----------|-------------|
| `cert-resources` | ClusterIssuers and Certificates for TLS |
| `cloudflare-resources` | Cloudflare tunnel and DNS configurations |
| `istio-resources` | Istio VirtualServices, DestinationRules, and gateways |

## Ingress controllers

In `kubernetes/cluster/active/ingress-controllers/`:

| Controller | Description |
|------------|-------------|
| `istio/istio-gateway` | Istio ingress gateway |
| `tailscale-operator` | Tailscale-based ingress |
