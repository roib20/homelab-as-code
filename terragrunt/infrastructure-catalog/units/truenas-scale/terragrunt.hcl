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

########################################
# ── DEPENDENCY ON FILE DOWNLOAD UNIT ──
########################################
dependency "download_file" {
  config_path = "../download_file"

  # Let ‘terragrunt plan’ succeed before the first real apply:
  mock_outputs = {
    downloaded_file_id = "datastore-name:iso/some-file.img"
  }
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  # VM identity
  vm_name = try(values.vm_name, "truenas-scale")
  vm_id   = try(values.vm_id, 2002)

  # Memory
  memory = {
    dedicated = try(values.memory_dedicated, 24576)
  }

  # Disk block
  disks = [
    {
      interface    = "virtio0"
      file_id      = dependency.download_file.outputs.downloaded_file_id
      datastore_id = try(values.vm_datastore_id, "TrueNAS")
      iothread     = true
      discard      = "on"
      size         = try(values.disk_size_gb, 64)
    },
    {
      interface    = "scsi0"
      datastore_id = try(values.vm_datastore_id, "TrueNAS")
      iothread     = true
      discard      = "on"
      ssd          = true
      size         = try(values.disk_size_gb, 64)
    },
  ]

  # Host PCI passthrough
  hostpci_devices = [
    {
      device  = "hostpci0"
      mapping = try(values.pci_mapping, "LSI")
      pcie    = true
      rombar  = true
    },
  ]

  # Networking
  network_devices = [
    {
      bridge = try(values.bridge, "vmbr0")
    },
  ]

  # Optional block toggles
  optional_blocks = {
    agent     = true
    cpu       = true
    memory    = true
    disk      = true
    efi_disk  = true
    hostpci   = true
    network_device = true
  }

  # CPU (example values; customize if needed)
  cpu = {
    type = "host"
  }

  # EFI Disk (optional customization)
  efi_disk = {
    datastore_id      = try(values.vm_datastore_id, "TrueNAS")
    type              = "4m"
    pre_enrolled_keys = true
  }

  # Agent
  agent = {
    enabled = true
  }
}
