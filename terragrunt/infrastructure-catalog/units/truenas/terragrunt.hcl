include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox_provider" {
  path = find_in_parent_folders("_envcommon/proxmox-provider.hcl")
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
  vm_name = try(values.vm_name, "local-btrfs-scale")
  vm_id   = try(values.vm_id, 2002)

  # BIOS
  bios = "ovmf"

  # Memory
  memory = {
    dedicated = try(values.memory_dedicated, 24576)
  }

  # Disk block
  disks = [
    {
      interface    = "virtio0"
      datastore_id = try(values.vm_datastore_id, "local-btrfs")
      iothread     = true
      discard      = "on"
      size         = try(values.disk_size_gb, 32)
    },
    {
      interface    = "scsi0"
      datastore_id = try(values.vm_datastore_id, "local-btrfs")
      iothread     = true
      discard      = "on"
      ssd          = true
      size         = try(values.disk_size_gb, 32)
      file_id      = dependency.download_file.outputs.downloaded_file_id
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

  # CPU
  cpu = {
    type = "host"
  }

  # EFI Disk
  efi_disk = {
    datastore_id      = try(values.vm_datastore_id, "local-btrfs")
    type              = "4m"
    pre_enrolled_keys = false
  }

  # Agent
  agent = {
    enabled = true
  }

  # Boot order
  boot_order = ["virtio0", "scsi0", "net0"]
}
