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
    url                = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
    checksum           = "0921d8b297c63ac458d8a06f87cd4c353f751eb5fe30fd0d839ca09c0833d1d9934b02ee14bbd0c0ec4f8917dde793957801ae1af3c8122cdf28dde8f3c3e0da"
    checksum_algorithm = "sha512"
    datastore_id       = "local"
  }
}

unit "vm-1" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm-1"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.11"
  }
}

unit "vm-2" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm-2"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.12"
  }
}

unit "vm-3" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm-3"

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
