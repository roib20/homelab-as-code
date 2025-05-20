########################################################
# Resources
########################################################

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type       = "iso"
  datastore_id       = var.iso_datastore_id
  node_name          = var.node_name

  url                = var.iso_url
  checksum           = var.iso_checksum
  checksum_algorithm = var.iso_checksum_algorithm
}

data "local_file" "ssh_public_key" {
  filename = "./id_rsa.pub"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  template  = false
  started   = true

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terragrunt"
  tags        = ["terragrunt"]

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
    user_account {
      username = var.username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  agent {
    enabled = var.agent
  }

  operating_system {
    type = "l26"
  }

  cpu {
    type = "host"
  }

  memory {
    dedicated = var.memory_dedicated
  }

  scsi_hardware = "virtio-scsi-single"

  ##### Primary boot disk (ISO) #####
  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb
  }

  ##### EFI disk #####
  efi_disk {
    datastore_id      = var.vm_datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  ##### CD-ROM #####
  cdrom {
    interface = "ide0"
  }

  ##### Network device #####
  network_device {
    bridge = var.bridge
  }
}

resource "terraform_data" "qemu-guest-agent" {
  depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]

  connection {
    type        = "ssh"
    host        = var.ipv4_address
    user        = var.username
    agent       = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade --assume-yes && sudo apt-get install --assume-yes qemu-guest-agent"
    ]
  }
}
