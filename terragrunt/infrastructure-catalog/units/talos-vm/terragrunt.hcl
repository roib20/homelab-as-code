include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."

  agent = try(values.agent.enabled, true)
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

dependencies {
  paths = [
            "../cloud-config/control-plane-01",
            "../cloud-config/control-plane-02",
            "../cloud-config/control-plane-03",
          ]
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  # VM identity
  vm_name = try(values.vm_name, "talos-vm")
  vm_id   = try(values.vm_id, 4000)

  # Storage & resources
  vm_datastore_id  = try(values.vm_datastore_id, "VM")

  agent = {
    enabled = local.agent
  }

  stop_on_destroy = local.agent ? false : true

  # Networking
  network_devices = [
    {
      bridge = try(values.bridge, "vmbr0")
    },
  ]

  # CPU
  cpu = {
    type = "host"
    cores = try(values.cpu_cores, 2)
  }

  # Memory
  memory = {
    dedicated = try(values.memory, 4096)
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
    meta_data_file_id = "${try(values.snippets_datastore_id, "local")}:snippets/${values.meta_data_cloud_config_file_name}"


    dns = {
      servers = ["1.1.1.1", "1.0.0.1"]
    }
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
  }
}

