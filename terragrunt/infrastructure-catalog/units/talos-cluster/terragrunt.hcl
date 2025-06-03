locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."

  cluster_name     = "${basename(get_terragrunt_dir())}"
  cluster_endpoint = "192.168.1.51" #"${local.cluster_name}.k8s.lan}"
#   tld              = ""
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/cluster"
}

include "common" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/common.hcl"
  expose = true
}

dependencies {
  paths = ["../talos-control-plane-01", "../talos-control-plane-02", "../talos-control-plane-03"]
}

inputs = {
    # cluster_name     = local.cluster_name
    cluster_name     = "talos"
    cluster_endpoint = local.cluster_endpoint
    # tld              = local.tld

    cluster_vip            = "192.168.1.60"
    cluster_node_subnet    = "192.168.1.0/24"
    cluster_pod_subnet     = "10.244.0.0/16"
    cluster_service_subnet = "10.96.0.0/12"

    kubernetes_version = try(value.kubernetes_version, "1.33.1")
    talos_version      = try(value.talos_version, "v1.10.3")
    flux_version       = try(value.flux_version, "v2.6.0")
    prometheus_version = try(value.prometheus_version, "17.0.2")
    cilium_version     = try(value.cilium_version, "1.17.4")
    cilium_helm_values = file("${get_terragrunt_dir()}/../../../../kubernetes/manifests/helm-release/cilium/values.yaml")

    timeout = "10m"

    machines = {
        node1 = {
            type = "controlplane"
            install = {
                disk       = "/dev/vda"
                extensions = [
                    "siderolabs/i915",
                    "siderolabs/intel-ucode",
                    "siderolabs/iscsi-tools",
                    "siderolabs/qemu-guest-agent",
                    "siderolabs/tailscale",
                    "siderolabs/util-linux-tools",
                ]
            }
            interfaces = [{
                addresses  = ["192.168.1.51"]
            }]
        }
        node2 = {
            type = "controlplane"
            install = {
                disk       = "/dev/vda"
                extensions = [
                    "siderolabs/i915",
                    "siderolabs/intel-ucode",
                    "siderolabs/iscsi-tools",
                    "siderolabs/qemu-guest-agent",
                    "siderolabs/tailscale",
                    "siderolabs/util-linux-tools",
                ]
            }
            interfaces = [{
                addresses  = ["192.168.1.52"]
            }]
        }
        node3 = {
            type = "controlplane"
            install = {
                disk       = "/dev/vda"
                extensions = [
                    "siderolabs/i915",
                    "siderolabs/intel-ucode",
                    "siderolabs/iscsi-tools",
                    "siderolabs/qemu-guest-agent",
                    "siderolabs/tailscale",
                    "siderolabs/util-linux-tools",
                ]
            }
            interfaces = [{
                addresses  = ["192.168.1.53"]
            }]
        }
    }
}
