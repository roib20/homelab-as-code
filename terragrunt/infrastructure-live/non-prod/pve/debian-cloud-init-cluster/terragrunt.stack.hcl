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
    node_name              = "${local.node_name}"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"
  }
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_names         = ["${local.node_name}"]
    url                = "https://cloud.debian.org/images/cloud/trixie-backports/20251129-2311/debian-13-backports-genericcloud-amd64-20251129-2311.qcow2"
    file_name          = "debian-13-backports-genericcloud-amd64.img"
    checksum           = "35a7afe5f77463066a81e55d619bc7e775d17b90ef425ac70e39e1ae55de59fd68071b2285a539ca1b3f645263d7ebf77394a01697f1b8086938b9204325dc9a"
    checksum_algorithm = "sha512"
    datastore_id       = "local"
  }
}

unit "vm-1" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-init-vm"

  path = "vm-1"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.11"
  }
}

unit "vm-2" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-init-vm"

  path = "vm-2"

  values = {
    node_name    = "${local.node_name}"
    ipv4_address = "192.168.1.12"
  }
}

unit "vm-3" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-init-vm"

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
