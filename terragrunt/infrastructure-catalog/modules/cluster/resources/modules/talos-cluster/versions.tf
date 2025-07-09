terraform {
  required_version = ">= 1.10.2"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
