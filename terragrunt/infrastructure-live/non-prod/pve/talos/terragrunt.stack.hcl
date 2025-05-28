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

  controlplane_nodes = [
    {
      name     = "talos-control-plane-01"
      ip       = "192.168.1.51"
      path     = "talos-control-plane-01"
    },
    {
      name     = "talos-control-plane-02"
      ip       = "192.168.1.52"
      path     = "talos-control-plane-02"
    },
    {
      name     = "talos-control-plane-03"
      ip       = "192.168.1.53"
      path     = "talos-control-plane-03"
    },
  ]

  worker_nodes = []
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"

  path = "download_file"

  values = {
    node_name = "${local.node_name}"
    
    datastore_id        = "local"

    # Talos Image Factory
    talos_version       = "v1.10.2"
    talos_platform      = "nocloud"
    talos_arch          = "amd64"
  }
}

unit "$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[0].path}"
  values = {
    node_name     = local.node_name
    vm_name       = local.controlplane_nodes[0].name
    ipv4_address  = local.controlplane_nodes[0].ip
  }
}

unit "$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[1].path}"
  values = {
    node_name     = local.node_name
    vm_name       = local.controlplane_nodes[1].name
    ipv4_address  = local.controlplane_nodes[1].ip
  }
}

unit "$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[2].path}"
  values = {
    node_name     = local.node_name
    vm_name       = local.controlplane_nodes[2].name
    ipv4_address  = local.controlplane_nodes[2].ip
  }
}

unit "talos-cluster" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos"

  path = "talos-cluster"

  values = {
    node_name = "${local.node_name}"

    cluster_endpoint = "${local.controlplane_nodes[0].ip}"

    node_data = {
      controlplanes = {
        for node in local.controlplane_nodes :
        node.ip => {
          install_disk = try(values.install_disk, "/dev/vda")
          hostname     = node.name
        }
      }

      workers = {
        for node in local.worker_nodes :
        node.ip => {
          install_disk = try(values.install_disk, "/dev/vda")
          hostname     = node.name
        }
      }
    }
  }
}
