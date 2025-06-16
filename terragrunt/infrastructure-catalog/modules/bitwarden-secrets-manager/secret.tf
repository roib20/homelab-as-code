data "bitwarden_secret" "secret_key" {
  organization_id = var.organization_id
  key             = var.secret_key
}
