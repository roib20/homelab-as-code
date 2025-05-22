include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/ubuntu"
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  # ISO download
  iso_url                = try(values.iso_url, "https://cloud-images.ubuntu.com/releases/noble/release-20250516/ubuntu-24.04-server-cloudimg-amd64.img")
  iso_checksum           = try(values.iso_checksum, "8d6161defd323d24d66f85dda40e64e2b9021aefa4ca879dcbc4ec775ad1bbc5")
  iso_checksum_algorithm = try(values.iso_checksum_algorithm, "sha256")
  iso_datastore_id       = try(values.iso_datastore_id, "local")

  # VM identity
  vm_name = try(values.vm_name, "")      # leave empty or override via values
  vm_id   = try(values.vm_id, 4001)

  # Storage & resources
  vm_datastore_id  = try(values.vm_datastore_id, "VM")
  memory_dedicated = try(values.memory_dedicated, 4096)
  disk_size_gb     = try(values.disk_size_gb, 32)

  # IPv4
  ipv4_address = try(values.ipv4_address, "192.168.1.21")
}
