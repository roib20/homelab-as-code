output "secret_key" {
  value     = var.secret_key
  sensitive = true
}

output "secret_value" {
  value     = data.bitwarden_secret.secret_key.value
  sensitive = true
}
