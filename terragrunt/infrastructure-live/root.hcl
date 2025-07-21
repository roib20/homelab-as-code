locals {
  envcommon = "${get_parent_terragrunt_dir()}/_envcommon"

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load node-level variables
  node_vars = read_terragrunt_config(find_in_parent_folders("node.hcl"))

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

generate "shared_tf" {
  path      = "zz_generated_shared.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    ${file("${local.envcommon}/versions.tf")}
  EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.node_vars.locals,
)
