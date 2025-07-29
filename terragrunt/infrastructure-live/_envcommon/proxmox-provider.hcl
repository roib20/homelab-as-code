locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load node-level variables (try nodes.hcl first, then node.hcl for backward compatibility)
  node_vars = try(
    read_terragrunt_config(find_in_parent_folders("nodes.hcl")),
    read_terragrunt_config(find_in_parent_folders("node.hcl"))
  )

  # Extract the variables we need for easy access
  virtual_environment_endpoint              = local.account_vars.locals.virtual_environment_endpoint
  virtual_environment_api_token             = local.account_vars.locals.virtual_environment_api_token
  virtual_environment_username              = local.account_vars.locals.virtual_environment_username
  virtual_environment_password              = local.account_vars.locals.virtual_environment_password
  virtual_environment_auth_ticket           = local.account_vars.locals.virtual_environment_auth_ticket
  virtual_environment_csrf_prevention_token = local.account_vars.locals.virtual_environment_csrf_prevention_token
  node_name                                 = local.node_vars.locals.node_name
  node_address                              = local.node_vars.locals.node_address
}

generate "proxmox_versions" {
  path      = "versions.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  required_version = ">= 1.10.2"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}
EOF
}

generate "proxmox_provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  endpoint    = "${local.virtual_environment_endpoint}"
  api_token   = "${local.virtual_environment_api_token}"
  insecure    = true

  ssh {
    agent     = true
    username  = "${local.virtual_environment_username}"
    password  = "${local.virtual_environment_password}"
  }
}
EOF
}

# Configure root level variables that all resources can inherit
inputs = merge(
  local.account_vars.locals,
  local.node_vars.locals,
)
