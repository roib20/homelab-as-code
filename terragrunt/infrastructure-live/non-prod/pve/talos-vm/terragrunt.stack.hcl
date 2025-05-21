locals {
  # Automatically load node-level variables
  node_vars = read_terragrunt_config(find_in_parent_folders("node.hcl"))

  # Extract the variables we need for easy access
  node_name = local.node_vars.locals.node_name

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

unit "talos-vm" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"

  path = "talos-vm"

  values = {
    node_name = "${local.node_name}"
    vm_name   = "talos-vm"
  }
}
