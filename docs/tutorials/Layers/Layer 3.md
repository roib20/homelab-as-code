# Layer 3: Terragrunt with OpenTofu (TrueNAS)

1. Enable root user. Run `sudo passwd root` using Ansible:

  ```shell
      export ROOT_PASS=""
  ansible -i inventory.yml all -b -K \
    -m ansible.builtin.shell \
    -a 'pw_b64="{{ lookup("env","ROOT_PASS") | b64encode }}"; pw="$(printf "%s" "$pw_b64" | base64 -d)"; printf "root:%s\n" "$pw" | chpasswd'
  ```

2. Create the TrueNAS virtual machine:

  ```shell
  docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "pushd terragrunt/infrastructure-live/prod/pve-node-01/truenas && terragrunt stack run apply -non-interactive"
  ```

3. While the Terrragrunt command is running, progress through the TrueNAS installer through the Proxmox VE Web UI. Once the TrueNAS install is complete, the command would succeed.

4. Either restore TrueNAS from backup or configure from scratch. Ensure that any existing ZFS volumes mount correctly.
