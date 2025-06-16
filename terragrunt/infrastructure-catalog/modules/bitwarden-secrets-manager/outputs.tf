output "secret_key" {
  value     = var.secret_key
  sensitive = true
}

output "secret_value" {
  value     = data.bitwarden_secret.secret_key.value
  sensitive = true
}

output "organization_id" {
  value     = var.organization_id
  sensitive = true
}

output "project_id" {
  value     = try(data.bitwarden_secret.secret_key.project_id, null)
  sensitive = true
}
