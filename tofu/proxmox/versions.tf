terraform {
  # OpenTofu version
  required_version = "~> 1.9.1"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}
