---
sidebar_position: 1
title: Prerequisites
---

# Prerequisites

This guide lists the hardware, accounts, and local tooling required before you start the layered tutorials.

## Hardware

- At least three x86_64 nodes for the Talos cluster
- Reliable local network with wired Ethernet
- Optional but recommended UPS for power stability

## Accounts and services

- Cloudflare account with R2 enabled
- Bitwarden Secrets Manager organization and project
- Tailscale account (used for secure access during provisioning)

## Local tooling

- Docker Engine and Docker Compose
- Git
- Optional: the Task runner (`task`) for convenience on the host

## Access and files

- SSH keypair available in `~/.ssh` for provisioning
- Local directories `~/.kube` and `~/.talos` (the runner mounts them)

## Next steps

- [Build the runner container](build-runner)
- [Configure environment variables](configure-env)
- [Configure Bitwarden Secrets Manager](setup-bitwarden)
- [Configure Cloudflare integration](setup-cloudflare)
- [Bootstrap the R2 bucket](bootstrap-r2)
- [Scale the cluster](scale-cluster)
