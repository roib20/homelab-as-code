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
  node_name              = values.node_name
  user_data_cloud_config = try(values.user_data_cloud_config, "user-data-cloud-config.yaml")
}
