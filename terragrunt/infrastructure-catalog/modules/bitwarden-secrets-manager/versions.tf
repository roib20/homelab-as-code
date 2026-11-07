terraform {
  # renovate: datasource=github-releases depName=opentofu/opentofu versioning=hashicorp extractVersion=^v(?<version>.*)$
  required_version = ">= 1.13.9"

  required_providers {
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.22"
    }
  }
}
