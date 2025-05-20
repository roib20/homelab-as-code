resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type       = "iso"
  datastore_id       = var.iso_datastore_id
  node_name          = var.node_name

  file_name          = "talos-${var.talos_version}-nocloud-amd64.img"
  url                = "https://factory.talos.dev/image/${var.talos_image_schematic_id}/${var.talos_version}/nocloud-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "talos_vm" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  description = "Managed by Terragrunt"
  tags        = ["terragrunt", "talos"]
  on_boot     = false

  cpu {
    cores = var.cpu_cores
    type = "x86-64-v2-AES"
  }

  agent {
    enabled = var.agent
  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = var.memory_dedicated
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb
  }

  initialization {
    datastore_id = var.vm_datastore_id
    ip_config {
      ipv4 {
        address = "${var.ipv4_address}/24"
        gateway = var.ipv4_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
  ##### Network device #####
  network_device {
    bridge = var.bridge
  }
}
