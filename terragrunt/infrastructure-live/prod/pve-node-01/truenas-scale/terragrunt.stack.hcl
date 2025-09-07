locals {
  # Environment, such as "prod" or "non-prod"
  environment = "prod"

  # Root "terragrunt/infrastructure-live" directory, containing "prod" and "non-prod" directories
  root_dir = "${dirname(find_in_parent_folders("root.hcl"))}"

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${local.root_dir}/.."

  # Automatically load node-level variables
  node_vars = read_terragrunt_config("${local.root_dir}/${local.environment}/pve/node.hcl")

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_names         = ["${local.node_name}"]
    url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.0/TrueNAS-SCALE-25.04.0.iso"
    checksum           = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
    checksum_algorithm = "sha256"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/truenas-scale"

  path = "vm"

  values = {
    node_name = "${local.node_name}"
    # vm_name   = "truenas-scale"
    vm_id = 2001
  }
}
