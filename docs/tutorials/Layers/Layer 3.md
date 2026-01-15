# Layer 3: Terragrunt with OpenTofu (TrueNAS)

Provision the TrueNAS VM and supporting infrastructure using Terragrunt.

## What this layer does

- Creates the TrueNAS VM on Proxmox
- Sets up Terragrunt state in Cloudflare R2
- Prepares storage for Kubernetes workloads

## Steps

1. Bootstrap the R2 bucket if you have not already:

   ```shell
   cd tofu/bootstrap-r2-bucket
   ./init.sh
   ```

   See [Bootstrap the R2 Bucket](../../how-to-guides/bootstrap-r2).

2. Enable the root user password (used by TrueNAS setup) via Ansible. Run this on the host or inside the runner container shell:

   ```shell
   task docker:shell
   export ROOT_PASS=""
   ansible -i ansible/pve-cluster/inventory.yml all -b -K \
     -m ansible.builtin.shell \
     -a 'pw_b64="{{ lookup("env","ROOT_PASS") | b64encode }}"; pw="$(printf "%s" "$pw_b64" | base64 -d)"; printf "root:%s\n" "$pw" | chpasswd'
   ```

3. Create the TrueNAS VM:

   ```shell
   docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "pushd terragrunt/infrastructure-live/prod/pve-node-01/truenas && terragrunt stack run apply -non-interactive"
   ```

4. While Terragrunt runs, complete the TrueNAS installer through the Proxmox UI.
5. Restore TrueNAS from backup or configure it from scratch.

## Verification

- Confirm the VM boots and the TrueNAS UI is reachable.
- Verify any expected storage pools are online.

## Next step

Proceed to [Layer 4: Taskfile (Talos Cluster)](Layer%204).

## Troubleshooting

- If Terragrunt fails, verify R2 credentials in `.env`.
- If the VM fails to boot, confirm the Proxmox ISO and storage settings.
- If the TrueNAS UI is unreachable, check VM network settings.
