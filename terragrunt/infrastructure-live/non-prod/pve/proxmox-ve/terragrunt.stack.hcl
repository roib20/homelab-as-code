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

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_names         = ["${local.node_name}"]
    url                = "https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso"
    checksum           = "6d8f5afc78c0c66812d7272cde7c8b98be7eb54401ceb045400db05eb5ae6d22"
    checksum_algorithm = "sha256"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.11"
  }
}
