terraform {
  # renovate: datasource=github-releases depName=opentofu/opentofu versioning=hashicorp extractVersion=^v(?<version>.*)$
  required_version = ">= 1.12.2"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.109"
    }
  }
}
