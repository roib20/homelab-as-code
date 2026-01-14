# Taskfile Commands

All tasks are defined in `Taskfile.yaml` and `.taskfiles/`. Run tasks using `task <namespace>:<command>`.

## cluster

Cluster lifecycle management.

| Command | Description |
|---------|-------------|
| `cluster:up` | Provision the cluster end-to-end |
| `cluster:down` | Destroy cluster with confirmation prompt |
| `cluster:down-dryrun` | Show what would be destroyed |
| `cluster:rebuild` | Destroy and rebuild cluster |
| `cluster:status` | Check cluster health and status |
| `cluster:info` | Show cluster information and Argo CD access details |

## talos

Talos cluster infrastructure via Terragrunt.

| Command | Description |
|---------|-------------|
| `talos:apply` | Apply Talos cluster (non-interactive) |
| `talos:destroy` | Destroy Talos cluster infrastructure |
| `talos:plan` | Show what would be applied |
| `talos:plan-destroy` | Show what would be destroyed |

## k8s

Kubernetes deployment and management.

| Command | Description |
|---------|-------------|
| `k8s:deploy` | Run K8s Ansible playbook |
| `k8s:bootstrap-secrets` | Apply bootstrap-k8s-secrets via Terragrunt |
| `k8s:delete-all-ingress` | Delete all ingress resources across all namespaces |
| `k8s:delete-all-ingress-dryrun` | Show what ingress resources would be deleted |

## argocd

Argo CD management.

| Command | Description |
|---------|-------------|
| `argocd` | Get admin password and start port-forward |
| `argocd:password` | Get Argo CD initial admin password |
| `argocd:port-forward` | Start port-forward to Argo CD server |
| `argocd:reset-password` | Reset Argo CD admin password (3-step process) |
| `argocd:delete-initial-secret` | Delete the initial admin secret |
| `argocd:disable-sync` | Disable Argo CD sync (scale controller to 0) |
| `argocd:enable-sync` | Enable Argo CD sync (scale controller to 1) |

## cloudflare

Cloudflare operator resource management.

| Command | Description |
|---------|-------------|
| `cloudflare:clean` | Delete all Cloudflare operator resources |
| `cloudflare:clean-dryrun` | Show what resources would be deleted |
| `cloudflare:list` | List all Cloudflare operator resources |
| `cloudflare:status` | Show operator and resource status |
| `cloudflare:info` | Show operator information and available resources |

## proxmox

Proxmox cluster management.

| Command | Description |
|---------|-------------|
| `proxmox:setup-cluster` | Run Proxmox cluster Ansible playbook |

## Configuration variables

These variables are set in `Taskfile.yaml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `ANSIBLE_DIR` | `ansible` | Ansible directory path |
| `TERRAGRUNT_DIR` | `terragrunt/infrastructure-live` | Terragrunt live directory |
| `TERRAGRUNT_ENV` | `prod` | Environment (prod/non-prod) |
| `PVE_NODE` | `multi-node` | Proxmox node configuration |
