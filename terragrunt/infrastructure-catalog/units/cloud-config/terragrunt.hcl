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
  node_name = values.node_name
  user_data_cloud_config = try(values.user_data_cloud_config, "user-data-cloud-config.yaml")
  cluster_name = values.cluster_name
  zone = values.zone
  hostname = values.hostname
  vm_id = values.vm_id
  instance_type = values.instance_type
}
