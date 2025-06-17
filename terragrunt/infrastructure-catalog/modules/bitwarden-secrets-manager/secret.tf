data "bitwarden_secret" "secret_key" {
  organization_id = try(var.organization_id, null)
  key             = var.secret_key
}
