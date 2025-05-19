resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = "ubuntu"
  node_name = "pve"
  vm_id     = 3001

  template = false
  started  = true

  operating_system {
    type = "l26"
  }

  cpu {
    type   = "host"
    cores  = 4
    sockets = 1
  }

  memory {
    dedicated = 8192
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    size         = 32
    iothread     = true
  }

  network_device {
    bridge = "vmbr0"
  }
}
