locals {
  # Automatically load node-level variables
  node_vars = read_terragrunt_config(find_in_parent_folders("node.hcl"))

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."

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
