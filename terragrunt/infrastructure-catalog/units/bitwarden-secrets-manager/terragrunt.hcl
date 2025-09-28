include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/bitwarden-secrets-manager"
}

inputs = {
  # Bitwarden Secrets Manager variables
  bws_access_token = values.bws_access_token
  secret_key       = values.secret_key
  organization_id  = try(values.organization_id, null)
  project_id       = try(values.project_id, null)
}
