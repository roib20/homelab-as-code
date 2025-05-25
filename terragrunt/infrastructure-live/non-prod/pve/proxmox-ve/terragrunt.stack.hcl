locals {
  # Automatically load node-level variables
  node_vars = read_terragrunt_config(find_in_parent_folders("node.hcl"))

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."

  ipv4_address = "192.168.1.22"
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_name = "${local.node_name}"
    url                = "https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso"
    checksum           = "d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
    checksum_algorithm = "sha256"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/secureboot-vm"

  path = "vm"

  values = {
    node_name = "${local.node_name}"
    ipv4_address = "192.168.1.11"
  }
}
