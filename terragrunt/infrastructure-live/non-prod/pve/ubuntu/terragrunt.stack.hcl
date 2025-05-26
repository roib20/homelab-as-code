locals {
  # Environment, such as "prod" or "non-prod"
  environment = "non-prod"
  
  # Root "terragrunt/infrastructure-live" directory, containing "prod" and "non-prod" directories
  root_dir = "${dirname(find_in_parent_folders("root.hcl"))}"

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${local.root_dir}/.."

  # Automatically load node-level variables
  node_vars = read_terragrunt_config("${local.root_dir}/${local.environment}/pve/node.hcl")

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name

  ipv4_address = "192.168.1.22"
}

unit "cloud-config" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-config"

  path = "cloud-config"

  values = {
    node_name = "${local.node_name}"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"
  }
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_name = "${local.node_name}"
    url                = "https://cloud-images.ubuntu.com/releases/noble/release-20250516/ubuntu-24.04-server-cloudimg-amd64.img"
    checksum           = "8d6161defd323d24d66f85dda40e64e2b9021aefa4ca879dcbc4ec775ad1bbc5"
    checksum_algorithm = "sha256"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-init-vm"

  path = "vm"

  values = {
    node_name = "${local.node_name}"
    ipv4_address = "${local.ipv4_address}"
  }
}

unit "qemu-guest-agent" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/qemu-guest-agent"

  path = "qemu-guest-agent"

  values = {
    node_name = "${local.node_name}"
    host = "${local.ipv4_address}"
    user = "user"
  }
}
