# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/talos"
}

dependencies {
  paths = ["../talos-control-plane-01", "../talos-control-plane-02", "../talos-control-plane-03"]
}

inputs = {
  # Proxmox target
  node_name = try(values.node_name, "pve")

  cluster_name      = try(values.cluster_name, "talos-cluster")
  cluster_endpoint  = try(values.cluster_endpoint)
  talos_version     = try(values.talos_version, null)

  node_data = jsonencode(values.node_data)

  # node_data = {
  #   controlplanes = {
  #     ${dependency.control-plane-01.outputs.ipv4_addresses[0]} = {
  #       install_disk = try(values.install_disk, "/dev/vda")
  #       hostname = "control-plane-01"  # Optional
  #     }
  #     ${dependency.control-plane-02.outputs.ipv4_addresses[0]} = {
  #       install_disk = try(values.install_disk, "/dev/vda")
  #       hostname = "control-plane-01"  # Optional
  #     }
  #     ${dependency.control-plane-03.outputs.ipv4_addresses[0]} = {
  #       install_disk = try(values.install_disk, "/dev/vda")
  #       hostname = "control-plane-01"  # Optional
  #     }
  #     # Add more control plane nodes as needed
  #   }

  #   # workers = {
  #   #   values.worker-01_ip = {
  #   #     install_disk = try(values.install_disk, "/dev/vda")
  #   #     hostname = "worker-01"  # Optional
  #   #   }
  #   #   # Add more worker nodes as needed
  #   # }
  # }
}
