include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/cloud-config"
}

inputs = {
  # Bitwarden Secrets Manager variables
  bws_access_token        = values.bws_access_token
  secret_key              = values.secret_key
  organization_id         = values.organization_id
  project_id              = try(values.project_id, null)
}
