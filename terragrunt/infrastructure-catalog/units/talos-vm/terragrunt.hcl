include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/talos-vm"
}

inputs = {
  # Proxmox target
  node_name = "pve"

  # ISO download
  talos_version                      = "v1.10.2"
  talos_image_schematic_id           = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"

  # VM identity
  vm_name = "talos"          # leave empty or set e.g. "truenas"
  vm_id   = 4000        # override as needed

  # Storage & resources
  vm_datastore_id  = "VM"
  memory_dedicated = 4096
  disk_size_gb     = 32

  # IPv4
  ipv4_address = "192.168.1.20"
}
