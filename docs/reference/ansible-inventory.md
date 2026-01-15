---
sidebar_position: 16
title: Ansible Inventory
---

# Ansible Inventory

The Proxmox cluster inventory lives at `ansible/pve-cluster/inventory.yml`.

## Structure

- Hosts are grouped by CPU family or node role.
- `ansible_host` points to each node's reachable address.
- Common variables are defined under `pve.vars`.

## Common variables

- `ansible_user` defaults to `debian` after Layer 1.
- `ansible_port` is `22`.
- `ansible_ssh_common_args` disables strict host key checking.

## Related docs

- [Layer 2: Ansible (pve-cluster)](../tutorials/Layers/Layer%202)
- [Ansible Playbooks](ansible-playbooks)
