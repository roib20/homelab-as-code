locals {
  cluster_name     = "${basename(get_terragrunt_dir())}"
  cluster_endpoint = "192.168.1.51" #"${local.cluster_name}.k8s.lan}"
#   tld              = ""
}

# include "root" {
#   path = find_in_parent_folders("root.hcl")
# }

include "common" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/common.hcl"
  expose = true
}

terraform {
#   source = "${include.common.locals.base_source_url}"
    source = "/home/roib/github/homelab-as-code/terragrunt/infrastructure-catalog/modules/cluster"
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
    cluster_pod_subnet     = "172.22.0.0/16"
    cluster_service_subnet = "172.23.0.0/16"

    cluster_env_vars = {
        cluster_id            = 2
        cluster_ip_pool_start = "192.168.1.61"
        cluster_ip_pool_stop  = "192.168.1.69"
        cluster_l2_interfaces = "[\"ens1f0\"]"
        # internal_domain       = local.tld
        internal_ingress_ip   = "192.168.1.62"
        # external_domain       = local.tld
        external_ingress_ip   = "192.168.1.63"
    }

    prepare_longhorn     = true
    longhorn_mount_disk2 = false
    prepare_spegel       = true
    speedy_kernel_args   = true

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
                disk = "/dev/vda"
            }
            disks = []
            interfaces = [{
                addresses    = ["192.168.1.51"]
            }]
        }
        node2 = {
            type = "controlplane"
            install = {
                disk = "/dev/vda"
            }
            disks = []
            interfaces = [{
                addresses    = ["192.168.1.52"]
            }]
        }
        node3 = {
            type = "controlplane"
            install = {
                disk = "/dev/vda"
            }
            disks = []
            interfaces = [{
                addresses    = ["192.168.1.53"]
            }]
        }
    }
}
