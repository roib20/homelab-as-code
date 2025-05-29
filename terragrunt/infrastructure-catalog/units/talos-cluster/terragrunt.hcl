# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/talos-cluster"
}

dependencies {
  paths = ["../talos-control-plane-01", "../talos-control-plane-02", "../talos-control-plane-03"]
}

inputs = {
  # Talos and Kubernetes versions
  talos_version       = "v1.10.3"
  kubernetes_version  = "v1.33.1"

  # Talos cluster config YAML string
  talos_cluster_config = {
    clusterName   = "talos-cluster"
    controlPlane  = {
      endpoint = "https://192.168.1.51:6443"
    }
  }

  # Machine definitions
  machines = [
    {
      talos_config = jsonencode({
        type    = "controlplane"
        install = {
          disk = "/dev/vda"
        }
        network = {
          hostname   = "host1"
          interfaces = [
            {
              interface = "vmbr0"
              addresses = ["192.168.1.51/24"]
            }
          ]
        }
      })
      extensions   = ["siderolabs/qemu-guest-agent"]

      secureboot   = false
      architecture = "amd64"
      platform     = "nocloud"
      sbc          = ""
    },
    {
      talos_config = jsonencode({
        type    = "controlplane"
        install = {
          disk = "/dev/vda"
        }
        network = {
          hostname   = "host2"
          interfaces = [
            {
              interface = "vmbr0"
              addresses = ["192.168.1.52/24"]
            }
          ]
        }
      })
      extensions   = ["siderolabs/qemu-guest-agent"]
      secureboot   = false
      architecture = "amd64"
      platform     = "nocloud"
      sbc          = ""
    },
    {
      talos_config = jsonencode({
        type    = "controlplane"
        install = {
          disk = "/dev/vda"
        }
        network = {
          hostname   = "host3"
          interfaces = [
            {
              interface = "vmbr0"
              addresses = ["192.168.1.53/24"]
            }
          ]
        }
      })
      extensions   = ["siderolabs/qemu-guest-agent"]
      secureboot   = false
      architecture = "amd64"
      platform     = "nocloud"
      sbc          = ""
    },
  ]

  # # Helm charts to bootstrap
  # bootstrap_charts = [
  #   {
  #     repository = "https://helm.cilium.io/"
  #     chart      = "cilium"
  #     name       = "cilium"
  #     version    = ${local.cilium_version}
  #     namespace  = "kube-system"
  #     values     = ${local.cilium_helm_values}
  #   }
  # ]

  # Node destruction behavior
  on_destroy = {
    graceful = false
    reboot   = true
    reset    = true
  }

  # Config output paths
  talos_config_path      = "~/.talos"
  kubernetes_config_path = "~/.kube"

  # Cluster creation timeout
  timeout = "10m"
}
