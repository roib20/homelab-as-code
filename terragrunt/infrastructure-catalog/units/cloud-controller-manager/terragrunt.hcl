include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/cloud-controller-manager"
}

inputs = {
  node_name              = values.node_name
  datastore_id           = values.datastore_id
  content_type           = try(values.content_type, "snippets")
  user_data_cloud_config = try(values.user_data_cloud_config, "user-data-cloud-config.yaml")
  
  hostname               = values.hostname
  vm_id                  = values.vm_id
  region                 = values.region
  zone                   = values.zone
  cpu                    = values.cpu
  memory                 = values.memory
  
  meta_data_cloud_config = try(values.meta_data_cloud_config_file_name, "meta-data-cloud-config.yaml")
}
