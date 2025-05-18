resource "proxmox_virtual_environment_download_file" "truenas_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.0/TrueNAS-SCALE-25.04.0.iso"
  checksum           = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
  checksum_algorithm = "sha256"
}

resource "proxmox_virtual_environment_vm" "truenas" {
  name      = "truenas"
  node_name = "pve"
  vm_id     = 2000

  template = false
  started  = true

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  agent {
    enabled = false
  }

  operating_system {
    type = "l26"
  }

  cpu {
    type = "host"
  }

  memory {
    dedicated = 24576
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "TrueNAS"
    file_id      = proxmox_virtual_environment_download_file.truenas_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 64
  }

  disk {
    datastore_id = "TrueNAS"
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
    size         = 64
  }

  efi_disk {
    datastore_id = "TrueNAS"
    type         = "4m"
    pre_enrolled_keys = true
  }

  cdrom {
    interface = "ide0"
  }

  network_device {
    bridge = "vmbr0"
  }

  hostpci {
    device  = "hostpci0"
    mapping = "LSI"
    pcie    = true
    rombar  = true
  }
}
