include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."

  ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  agent = try(values.agent.enabled, false)
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

dependency "cloud-config" {
  config_path = "../cloud-config"

  mock_outputs = {
    user_data_cloud_config = "datastore-name:iso/some-file.img"
  }
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  agent = {
    enabled = local.agent
  }

  stop_on_destroy = local.agent ? false : true

  # VM identity
  vm_name = try(values.vm_name, null) # leave empty or override via values
  vm_id   = try(values.vm_id, null)   # leave empty or override via values

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

  # Memory
  memory = {
    dedicated = 2048
  }

  disks = [
    {
      interface    = "virtio0"
      file_id      = dependency.download_file.outputs.downloaded_file_id
      datastore_id = try(values.vm_datastore_id, "VM")
      iothread     = true
      discard      = "on"
      size         = try(values.disk_size_gb, 64)
    },
  ]

  # Cloud-init
  initialization = {
    datastore_id = try(values.vm_datastore_id, "VM")
    # user_data_file_id = dependency.cloud-config.outputs.user_data_cloud_config
    ip_config = [
      {
        ipv4 = {
          address = "${try("${values.ipv4_address}", "192.168.1.20")}/24"
          gateway = try(values.ipv4_gateway, "192.168.1.1")
        }
        ipv6 = {
          address = "dhcp"
        }
      }
    ]
    user_account = {
      username = try(values.username, "user")
      password = "123"
      keys     = "${local.ssh_public_key}"
    }
  }
}
