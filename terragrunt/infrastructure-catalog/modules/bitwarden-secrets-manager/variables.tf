variable "bws_access_token" {
  description = "Access token for Bitwarden Secrets Manager (Machine Account)"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "secret_key" {
  description = "The key (name) of the secret to retrieve (case-sensitive)"
  type        = string
  sensitive   = true
}

variable "organization_id" {
  description = "Bitwarden organization ID to use if organization_name is not set."
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "Bitwarden Project ID where the secret is stored"
  type        = string
  sensitive   = true
  nullable    = true
  default     = null
}
