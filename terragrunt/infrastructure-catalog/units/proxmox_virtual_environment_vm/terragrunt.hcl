include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/proxmox_virtual_environment_vm"
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  # VM identity
  vm_name = try(values.vm_name, null) # leave empty or override via values
  vm_id   = try(values.vm_id, null)   # leave empty or override via values

  # Networking
  network_devices = [
    {
      bridge = try(values.bridge, "vmbr0")
    },
  ]
}
