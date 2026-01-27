locals {
  cluster_endpoint_address = "https://${var.cluster_endpoint}:6443"

  talos_cluster_config = templatefile("${path.module}/resources/templates/talos_cluster.yaml.tftpl", {
    cluster_endpoint       = local.cluster_endpoint_address
    cluster_name           = var.cluster_name
    cluster_pod_subnet     = var.cluster_pod_subnet
    cluster_service_subnet = var.cluster_service_subnet
    cluster_node_subnet    = var.cluster_node_subnet
    cluster_extraManifests = local.extraManifests
  })

  machines = [
    for name, machine in var.machines : {
      talos_config = templatefile("${path.module}/resources/templates/talos_machine.yaml.tftpl", {
        cluster_node_subnet = var.cluster_node_subnet
        cluster_vip         = var.cluster_vip

        machine_hostname    = name
        machine_type        = machine.type
        machine_interfaces  = machine.interfaces
        machine_nameservers = var.nameservers
        machine_timeservers = var.timeservers
        machine_install     = machine.install
        machine_labels      = machine.labels
        machine_annotations = machine.annotations
        machine_files       = machine.files
      })
      hostname            = name
      primary_ip          = try(machine.interfaces[0].addresses[0], "")
      machine_interfaces  = machine.interfaces
      machine_nameservers = var.nameservers
      extensions          = machine.install.extensions
      extra_kernel_args   = machine.install.extra_kernel_args
      secureboot          = machine.install.secureboot
      architecture        = machine.install.architecture
      platform            = machine.install.platform
      sbc                 = machine.install.sbc
    }
  ]

  bootstrap_charts = [
    for chart in values(var.helm_charts) : {
      repository = chart.helm_repository
      chart      = chart.chart
      name       = chart.name
      version    = chart.chart_version
      namespace  = chart.namespace
      values     = chart.values
    }
  ]

  extraManifests = [
    # External Secrets CRDs
    "https://raw.githubusercontent.com/external-secrets/external-secrets/v${var.versions.external-secrets_version}/deploy/crds/bundle.yaml",

    # Gateway API CRDs: https://gateway-api.sigs.k8s.io/guides/getting-started/#installing-gateway-api
    "https://github.com/kubernetes-sigs/gateway-api/releases/download/v${var.versions.gateway-api_version}/${var.versions.gateway-api_channel}-install.yaml",
  ]
}

module "talos_cluster" {
  source = "./resources/modules/talos-cluster"

  versions               = var.versions
  talos_config_path      = var.talos_config_path
  kubernetes_config_path = var.kubernetes_config_path
  talos_cluster_config   = local.talos_cluster_config
  machines               = local.machines
  cluster_vip            = var.cluster_vip
  bootstrap_charts       = local.bootstrap_charts
  on_destroy             = var.cluster_on_destroy
  ts_authkey             = var.ts_authkey
}
