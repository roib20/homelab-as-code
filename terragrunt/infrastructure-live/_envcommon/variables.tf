# This file is no longer used
variable "virtual_environment_endpoint" {
  type     = string
  default  = "https://pve:8006/"
  nullable = false
}

variable "virtual_environment_ssh_username" {
  type     = string
  default  = "terraform"
  nullable = true
}

variable "virtual_environment_api_token" {
  type     = string
  default  = "user@pam!token=00000000-0000-0000-0000-000000000000"
  nullable = true
}

variable "virtual_environment_username" {
  type     = string
  default  = "terraform"
  nullable = true
}

variable "virtual_environment_password" {
  type     = string
  default  = null
  nullable = true
}

variable "virtual_environment_auth_ticket" {
  type     = string
  default  = null
  nullable = true
}

variable "virtual_environment_csrf_prevention_token" {
  type     = string
  default  = null
  nullable = true
}
