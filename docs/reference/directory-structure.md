# Directory Structure

Overview of the repository layout.

## Root directories

```text
homelab-as-code/
├── .github/workflows/    # CI/CD pipelines
├── .taskfiles/           # Modular Taskfile definitions
├── ansible/              # Ansible playbooks and roles
├── debian/               # Debian preseed configuration
├── docs/                 # Documentation (this site)
├── docusaurus/           # Docusaurus configuration
├── kubernetes/           # Kubernetes manifests
├── terragrunt/           # Infrastructure as code
└── tofu/                 # OpenTofu bootstrap scripts
```

## ansible/

Ansible playbooks organized by target system.

```text
ansible/
├── ansible-k8s/          # Kubernetes deployment playbook
│   ├── k8s-playbook.yml
│   └── roles/
├── pve-cluster/          # Proxmox cluster setup
│   ├── cluster-playbook.yml
│   ├── inventory.yml
│   └── roles/
└── pve-single-node/      # Single node Proxmox setup
    ├── pve-playbook.yml
    └── roles/
```

## kubernetes/

Kubernetes manifests follow Kustomize patterns and are grouped by lifecycle stage.

```text
kubernetes/
├── bootstrap/            # Initial Argo CD bootstrap
│   ├── app-of-apps.yaml
│   └── applicationsets/
├── hidden-secrets/       # Secret templates for bootstrap
└── cluster/
    ├── active/           # Enabled components
    │   ├── addons/       # Cluster addons
    │   ├── apps/         # User applications
    │   ├── argo/         # Argo CD configuration
    │   ├── ingress-controllers/
    │   ├── resources/    # Cluster-wide resources
    │   └── storage/      # Storage drivers and classes
    └── inactive/         # Disabled components
        ├── addons/
        ├── ingress-controllers/
        └── storage/
```

### bootstrap

- `app-of-apps.yaml` defines the root Argo CD application.
- `applicationsets/` defines the ApplicationSet generators:
  - `cluster-addons.yaml` targets `cluster/active/addons/`.
  - `cluster-apps.yaml` targets `cluster/active/apps/`.
  - `cluster-resources.yaml` targets `cluster/active/resources/`.
  - `cluster-ingress-controllers.yaml` targets `cluster/active/ingress-controllers/`.
  - `cluster-argo.yaml` targets Argo CD configuration.
  - `cluster-inactive.yaml` tracks disabled components.

### active components

- `addons/` contains cluster services. See [Addons Catalog](addons-catalog) and [Kubernetes Addons](kubernetes-addons).
- `apps/` contains user workloads. See [Application Catalog](application-catalog).
- `ingress-controllers/` contains gateways. See [Ingress Controllers](ingress-controllers).
- `resources/` contains shared resources. See [Cluster Resources](cluster-resources).
- `storage/` contains storage drivers and classes.

### inactive components

Inactive resources follow the same layout as `active/` but are not applied by Argo CD.

### hidden-secrets

`hidden-secrets/` stores templates for Bitwarden bootstrap secrets used by Terragrunt.

### Kustomize structure

Each addon, app, or resource follows this pattern:

```text
<component>/
├── base/
│   ├── kustomization.yaml
│   ├── values.yaml       # Helm values (if applicable)
│   └── namespace.yaml    # Namespace definition (optional)
└── overlays/
    └── prod/
        ├── config.json   # ApplicationSet configuration
        ├── kustomization.yaml
        └── values-override.yaml  # Override values (optional)
```

See [ApplicationSet Config Format](applicationset-config).

## terragrunt/

Infrastructure as code with Terragrunt and OpenTofu.

```text
terragrunt/
├── infrastructure-catalog/
│   ├── modules/          # Reusable OpenTofu modules
│   └── units/            # Terragrunt unit configurations
└── infrastructure-live/
    ├── _envcommon/       # Shared configuration
    │   ├── common.hcl    # R2 backend configuration
    │   └── proxmox-provider.hcl
    ├── prod/             # Production environment
    │   ├── multi-node/   # Multi-node Talos cluster
    │   └── pve-node-*/   # Per-node configurations
    └── non-prod/         # Non-production testing
```

## .taskfiles/

Modular task definitions for the Task runner.

```text
.taskfiles/
├── argocd/Taskfile.yaml
├── cloudflare/Taskfile.yaml
├── cluster/Taskfile.yaml
├── common/scripts/       # Shared scripts
├── kubernetes/Taskfile.yaml
├── proxmox/Taskfile.yaml
└── talos/Taskfile.yaml
```

## Key files

| File | Purpose |
|------|---------|
| `Taskfile.yaml` | Root task definitions |
| `compose.yaml` | Docker Compose for runner container |
| `Dockerfile` | Multi-stage build for runner image |
| `docker-bake.hcl` | Docker Buildx configuration |
| `env.example` | Template for environment variables |
| `.pre-commit-config.yaml` | Pre-commit hooks configuration |
