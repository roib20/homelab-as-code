terraform {
  # renovate: datasource=github-releases depName=opentofu/opentofu versioning=hashicorp extractVersion=^v(?<version>.*)$
  required_version = ">= 1.12.1"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}
