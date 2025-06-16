provider "bitwarden" {
  experimental {
    embedded_client = true
  }
  access_token = var.bws_access_token
}
