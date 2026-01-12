terraform {
  required_version = ">= 1.11.0"

  required_providers {
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">= 0.13.6"
    }
  }
}
