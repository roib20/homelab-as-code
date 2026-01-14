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

Kubernetes manifests following Kustomize patterns.

```text
kubernetes/
├── bootstrap/            # Initial cluster bootstrap
│   ├── app-of-apps.yaml
│   └── applicationsets/  # Argo CD ApplicationSets
└── cluster/
    ├── active/           # Enabled components
    │   ├── addons/       # Cluster addons
    │   ├── apps/         # User applications
    │   ├── argo/         # Argo CD configuration
    │   ├── ingress-controllers/
    │   └── resources/    # Cluster-wide resources
    └── inactive/         # Disabled components
```

### Kustomize structure

Each addon or application follows this pattern:

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
