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

  talos_version = "v1.10.2"
  talos_image_schematic_id = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_name = "${local.node_name}"
    url                = "https://factory.talos.dev/image/${local.talos_image_schematic_id}/${local.talos_version}/nocloud-amd64.iso"
    datastore_id       = "local"
  }
}

unit "vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"

  path = "vm"

  values = {
    node_name = "${local.node_name}"
    vm_name   = "talos-vm"
  }
}
