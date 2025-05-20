########################################################
# Resources
########################################################

resource "proxmox_virtual_environment_download_file" "truenas_scale_cloud_image" {
  content_type       = "iso"
  datastore_id       = var.iso_datastore_id
  node_name          = var.node_name

  url                = var.iso_url
  checksum           = var.iso_checksum
  checksum_algorithm = var.iso_checksum_algorithm
}

resource "proxmox_virtual_environment_vm" "truenas" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  template  = false
  started   = true

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terragrunt"
  tags        = ["terragrunt"]

  agent {
    enabled = true
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
    file_id      = proxmox_virtual_environment_download_file.truenas_scale_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb
  }

  ##### Secondary data disk #####
  disk {
    datastore_id = var.vm_datastore_id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
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
    # file_id  = proxmox_virtual_environment_download_file.truenas_scale_cloud_image.id
  }

  ##### Network device #####
  network_device {
    bridge = var.bridge
  }

  ##### PCI passthrough #####
  hostpci {
    device  = var.pci_device
    mapping = var.pci_mapping
    pcie    = true
    rombar  = true
  }
}
