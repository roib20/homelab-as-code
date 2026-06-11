terraform {
  # renovate: datasource=github-releases depName=opentofu/opentofu versioning=hashicorp extractVersion=^v(?<version>.*)$
  required_version = ">= 1.12.1"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}
