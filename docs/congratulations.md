---
sidebar_position: 1
slug: /
title: Introduction
---

# Homelab as Code

Homelab as Code is a layered infrastructure stack for building a Talos-based Kubernetes cluster on Proxmox, managed end-to-end with GitOps.

## What this project provides

- Layered build path from bare metal to running apps
- Docker runner container with all required tooling
- GitOps delivery using Argo CD and ApplicationSets
- Infrastructure automation with Ansible, Terragrunt, and OpenTofu
- Secret and config bootstrap with Bitwarden Secrets Manager

## Quick start

1. Review [Prerequisites](how-to-guides/prerequisites).
2. Follow the [Getting Started](tutorials/getting-started) walkthrough.
3. Proceed through the [Layered Tutorials](tutorials/Layers/Layer%200).
4. Access the cluster via [Argo CD](how-to-guides/access-argocd).

## Documentation map

- [Tutorials](tutorials/): Guided, learning-oriented walkthroughs.
- [How-to guides](how-to-guides/): Task-focused operations and procedures.
- [Reference](reference/): Commands, configuration, and directory details.
- [Explanation](explanation/): Design rationale and architecture context.

## Recommended next reads

- [Architecture Overview](explanation/architecture-overview)
- [GitOps Workflow](explanation/gitops-workflow)
- [Networking Architecture](explanation/networking-architecture)
- [Secrets Management](explanation/secrets-management)
- [Configure Environment Variables](how-to-guides/configure-env)
- [Configure Bitwarden Secrets Manager](how-to-guides/setup-bitwarden)
- [Configure Cloudflare integration](how-to-guides/setup-cloudflare)
- [Troubleshooting](how-to-guides/troubleshooting)
- [Scale the Cluster](how-to-guides/scale-cluster)
