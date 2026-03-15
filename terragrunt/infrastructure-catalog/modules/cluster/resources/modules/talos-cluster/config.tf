locals {
  machines = { for v in var.machines : v.hostname => v }

  bootstrap_node     = [for k, v in local.machines : k if yamldecode(v.talos_config).type == "controlplane"][0]
  bootstrap_endpoint = [for k, v in local.machines : split("/", v.primary_ip)[0] if yamldecode(v.talos_config).type == "controlplane"][0]

  nodes            = [for k, v in local.machines : k]
  node_ips         = [for k, v in local.machines : split("/", v.primary_ip)[0]]
  controlplane_ips = [for k, v in local.machines : split("/", v.primary_ip)[0] if yamldecode(v.talos_config).type == "controlplane"]

  cluster_name     = try(yamldecode(var.talos_cluster_config).clusterName, "talos.local")
  cluster_endpoint = yamldecode(var.talos_cluster_config).controlPlane.endpoint

  extramounts = [
    "/var/mnt/longhorn", # Longhorn: https://longhorn.io/docs/latest/advanced-resources/os-distro-specific/talos-linux-support/
  ]
}

data "helm_template" "bootstrap_charts" {
  for_each = { for i, chart in var.bootstrap_charts : chart.name => chart }

  repository   = each.value.repository
  chart        = each.value.chart
  name         = each.value.name
  version      = each.value.version
  namespace    = each.value.namespace
  kube_version = var.versions.kubernetes_version
  values       = [each.value.values]
  include_crds = true
}

resource "talos_machine_secrets" "this" {
  talos_version = "v${var.versions.talos_version}"
}

data "talos_machine_configuration" "this" {
  for_each = local.machines

  cluster_name       = local.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  machine_type       = yamldecode(each.value.talos_config).type
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = "v${var.versions.kubernetes_version}"
  talos_version      = "v${var.versions.talos_version}"

  config_patches = compact([
    templatefile("${path.module}/resources/talos-patches/ccm.yaml.tftpl", {
      type = yamldecode(each.value.talos_config).type
    }),
    templatefile("${path.module}/resources/talos-patches/cluster.yaml.tftpl", {
      type           = yamldecode(each.value.talos_config).type
      cluster_config = var.talos_cluster_config
    }),
    templatefile("${path.module}/resources/talos-patches/coredns.yaml.tftpl", {
      disabled   = true
      clusterDNS = "10.96.0.10"
    }),
    templatefile("${path.module}/resources/talos-patches/cri.yaml.tftpl", {
      discard_unpacked_layers = false
      cdi = {
        staticPath  = "/var/cdi/static"
        dynamicPath = "/var/cdi/dynamic"
      }
    }),
    templatefile("${path.module}/resources/talos-patches/user-volume.yaml.tftpl", {
      user_volumes = [
        {
          name           = "longhorn"
          disk_name      = "vdb"
          disk_transport = "virtio"
          max_size       = "300GB"
          volumeType     = "partition"
          grow           = true
        }
      ]
    }),
    var.zswap.enabled ? templatefile("${path.module}/resources/talos-patches/swap-volume.yaml.tftpl", {}) : "",
    var.zswap.enabled ? templatefile("${path.module}/resources/talos-patches/zswap.yaml.tftpl", {
      max_pool_percent = var.zswap.max_pool_percent
      shrinker_enabled = var.zswap.shrinker_enabled
    }) : "",
    var.zswap.enabled ? templatefile("${path.module}/resources/talos-patches/kubelet-memory-swap.yaml.tftpl", {}) : "",
    templatefile("${path.module}/resources/talos-patches/extramount.yaml.tftpl", {
      extramounts = local.extramounts
    }),
    templatefile("${path.module}/resources/talos-patches/network-configuration.yaml.tftpl", {
      machine_hostname    = try(each.value.hostname, "")
      machine_nameservers = each.value.machine_nameservers
      machine_interfaces  = each.value.machine_interfaces
      machine_type        = yamldecode(each.value.talos_config).type
      cluster_vip         = var.cluster_vip
    }),
    templatefile("${path.module}/resources/talos-patches/inline_manifests.yaml.tftpl", {
      type      = yamldecode(each.value.talos_config).type
      manifests = data.helm_template.bootstrap_charts
    }),
    templatefile("${path.module}/resources/talos-patches/machine_hostdns.yaml.tftpl", {
      forwardKubeDNSToHost = false
    }),
    templatefile("${path.module}/resources/talos-patches/machine_install.yaml.tftpl", {
      machine_install_disk_image = each.value.secureboot ? local.machine_installer_secureboot[each.key] : local.machine_installer[each.key]
    }),
    templatefile("${path.module}/resources/talos-patches/machine_kernel.yaml.tftpl", {
      sysctls = {
        "vm.nr_hugepages" = "1024"
      }
      kernel_modules = [
        "binfmt_misc",
        "nvme_tcp",
        "vfio_pci",
        # "uio_pci_generic",
      ]
    }),
    templatefile("${path.module}/resources/talos-patches/machine.yaml.tftpl", {
      machine_config = each.value.talos_config
    }),
    templatefile("${path.module}/resources/talos-patches/tailscale.patch.yaml.tftpl", {
      TS_AUTHKEY  = var.ts_authkey
      TS_HOSTNAME = each.key
    }),
  ])
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.controlplane_ips
  nodes                = local.node_ips
}
