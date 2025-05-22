include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/truenas-scale"
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  # ISO download
  iso_url                = try(values.iso_url, "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.0/TrueNAS-SCALE-25.04.0.iso")
  iso_checksum           = try(values.iso_checksum, "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359")
  iso_checksum_algorithm = try(values.iso_checksum_algorithm, "sha256")
  iso_datastore_id       = try(values.iso_datastore_id, "local")

  # VM identity
  vm_name = try(values.vm_name, "truenas-scale")
  vm_id   = try(values.vm_id, 2000)

  # Storage & resources
  vm_datastore_id  = try(values.vm_datastore_id, "TrueNAS")
  memory_dedicated = try(values.memory_dedicated, 24576)
  disk_size_gb     = try(values.disk_size_gb, 64)

  # Networking & PCI passthrough
  bridge      = try(values.bridge, "vmbr0")
  pci_device  = try(values.pci_device, "hostpci0")
  pci_mapping = try(values.pci_mapping, "LSI")
}
