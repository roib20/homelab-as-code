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
  iso_url                = "https://download.sys.truenas.net/talos-vm-Fangtooth/25.04.0/talos-vm-25.04.0.iso"
  iso_checksum           = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
  iso_checksum_algorithm = "sha256"
  iso_datastore_id       = "local"

  # VM identity
  vm_name = ""          # leave empty or set e.g. "truenas"
  vm_id   = 2000        # override as needed

  # Storage & resources
  vm_datastore_id  = "TrueNAS"
  memory_dedicated = 24576
  disk_size_gb     = 64

  # Networking & PCI passthrough
  bridge      = "vmbr0"
  pci_device  = "hostpci0"
  pci_mapping = "LSI"
}
