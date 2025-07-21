include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/qemu-guest-agent"
}

dependency "vm" {
  config_path = "../vm"

  mock_outputs = {
    ipv4_addresses = ["192.168.1.2"]
  }
}

inputs = {
  connection = {
    type  = try(values.type, "ssh")
    host  = try(values.host, "${dependency.vm.outputs.ipv4_addresses}")
    user  = try(values.user, null)
    agent = try(values.agent, true)
  }
}
