# Layer 2: Ansible (pve-cluster)

1. Generate a new [Tailscale Auth key](https://login.tailscale.com/admin/settings/keys) with "Reuasable" and "Pre-approved" options enabled.
2. Export `TS_KEY` environment variable.
3. Run: `time ansible-playbook "ansible/pve-cluster/cluster-playbook.yml" --inventory="inventory.yml" --ask-pass -K`
