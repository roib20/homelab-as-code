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
    url                = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.3.0-amd64-netinst.iso"
    checksum           = "1ada40e4c938528dd8e6b9c88c19b978a0f8e2a6757b9cf634987012d37ec98503ebf3e05acbae9be4c0ec00b52e8852106de1bda93a2399d125facea45400f8"
    checksum_algorithm = "sha512"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.13"
  }
}

# unit "qemu-guest-agent" {
#   source = "${local.terragrunt_dir}/infrastructure-catalog/units/qemu-guest-agent"

#   path = "qemu-guest-agent"

#   values = {
#     node_name = "${local.node_name}"
#     host = "${local.ipv4_address}"
#     user = "user"
#   }
# }
