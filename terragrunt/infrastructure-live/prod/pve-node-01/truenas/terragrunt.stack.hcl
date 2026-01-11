locals {
  # Environment, such as "prod" or "non-prod"
  environment = "prod"

  # Root "terragrunt/infrastructure-live" directory, containing "prod" and "non-prod" directories
  root_dir = "${dirname(find_in_parent_folders("root.hcl"))}"

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${local.root_dir}/.."

  # Automatically load node-level variables
  node_vars = read_terragrunt_config("${local.root_dir}/${local.environment}/pve-node-01/node.hcl")

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_names         = ["${local.node_name}"]
    url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Goldeye/25.10.1/TrueNAS-SCALE-25.10.1.iso"
    checksum           = "d7e325c4e5416f52060f87ee337ae5a4c9c7bb16d34bfcad5e4a69c265ceb5d6"
    checksum_algorithm = "sha256"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/truenas"

  path = "vm"

  values = {
    node_name = "${local.node_name}"
    vm_name   = "TrueNAS"
    vm_id     = 2001
  }
}
