output "secret_value" {
  value     = data.bitwarden_secret.secret_key.value
  sensitive = true
}
