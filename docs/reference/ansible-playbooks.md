---
sidebar_position: 5
title: Ansible Playbooks
---

# Ansible Playbooks

Ansible playbooks live under `ansible/` and are grouped by target systems.

## Playbooks

| Path | Purpose |
| --- | --- |
| `ansible/pve-cluster/cluster-playbook.yml` | Configure a Proxmox cluster |
| `ansible/pve-single-node/pve-playbook.yml` | Configure a single Proxmox node |
| `ansible/pve-single-node/ping-playbook.yml` | Basic connectivity test |
| `ansible/ansible-k8s/k8s-playbook.yml` | Apply Kubernetes manifests |

## Related docs

- [Layer 2: Ansible (pve-cluster)](../tutorials/Layers/Layer%202)
- [Ansible Inventory](ansible-inventory)
- [Update the Cluster](../how-to-guides/update-cluster)
