terraform {
  required_version = "~> 1.9.1"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.8.1"
    }
  }
}
