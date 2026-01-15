# Layer 2: Ansible (pve-cluster)

Configure the Proxmox cluster using the `ansible/pve-cluster/cluster-playbook.yml` playbook.

## What this layer does

- Joins Proxmox nodes into a cluster
- Configures packages and common settings
- Prepares hosts for VM provisioning

## Steps

1. Generate a new [Tailscale Auth key](https://login.tailscale.com/admin/settings/keys) with "Reusable" and "Pre-approved" enabled.
2. Update the inventory file at `ansible/pve-cluster/inventory.yml` with node IPs.
3. Export the Tailscale key:

   ```shell
   export TS_KEY=""
   ```

4. Run the playbook using the runner container:

   ```shell
   docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "ansible-playbook ansible/pve-cluster/cluster-playbook.yml --inventory=ansible/pve-cluster/inventory.yml --ask-pass -K"
   ```

## Verification

- Confirm Proxmox nodes appear in the cluster UI.
- Verify the Tailscale devices show as connected.

## Next step

Proceed to [Layer 3: Terragrunt with OpenTofu](Layer%203).

## Troubleshooting

- If SSH fails, verify the node IPs and passwords.
- If Tailscale fails, regenerate the auth key with pre-approval enabled.
- If the playbook stops on privilege escalation, confirm sudo permissions.
