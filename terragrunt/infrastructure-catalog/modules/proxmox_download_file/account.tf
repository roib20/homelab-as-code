# Provider authentication variables
variable "virtual_environment_endpoint" {
  description = "The URL endpoint for the Proxmox VE API."
  type        = string
}

variable "virtual_environment_api_token" {
  description = "The API token for Proxmox VE."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "virtual_environment_username" {
  description = "The username for SSH access to Proxmox VE."
  type        = string
}

variable "virtual_environment_password" {
  description = "The password for SSH access to Proxmox VE."
  type        = string
  sensitive   = true
  ephemeral   = true
}
