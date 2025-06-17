locals {
  cluster_endpoint_address = "https://${var.cluster_endpoint}:6443"

  talos_cluster_config = templatefile("${path.module}/resources/templates/talos_cluster.yaml.tftpl", {
    cluster_endpoint       = local.cluster_endpoint_address
    cluster_name           = var.cluster_name
    cluster_pod_subnet     = var.cluster_pod_subnet
    cluster_service_subnet = var.cluster_service_subnet
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
      extensions        = machine.install.extensions
      extra_kernel_args = machine.install.extra_kernel_args
      secureboot        = machine.install.secureboot
      architecture      = machine.install.architecture
      platform          = machine.install.platform
      sbc               = machine.install.sbc
    }
  ]

  bootstrap_charts = [
    {
      repository = var.helm_charts["cilium"].helm_repository
      chart      = "cilium"
      name       = "cilium"
      version    = var.helm_charts["cilium"].chart_version
      namespace  = "kube-system"
      values     = var.helm_charts["cilium"].values
    },
    {
      repository = var.helm_charts["talos-ccm"].helm_repository
      chart      = "talos-cloud-controller-manager"
      name       = "talos-cloud-controller-manager"
      version    = var.helm_charts["talos-ccm"].chart_version
      namespace  = "kube-system"
      values     = var.helm_charts["talos-ccm"].values
    },
    {
      repository = var.helm_charts["cert-manager"].helm_repository
      chart      = "cert-manager"
      name       = "cert-manager"
      version    = var.helm_charts["cert-manager"].chart_version
      namespace  = "cert-manager"
      values     = var.helm_charts["cert-manager"].chart_version
    },
  ]

  extraManifests = [
    # Namespaces
    "https://github.com/cert-manager/cert-manager/blob/master/deploy/manifests/namespace.yaml",

    # Prometheus CRDs
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/prometheus-operator-crds-${var.prometheus_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-podmonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/prometheus-operator-crds-${var.prometheus_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-servicemonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/prometheus-operator-crds-${var.prometheus_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-probes.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/prometheus-operator-crds-${var.prometheus_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheusrules.yaml",
    # Gateway API CRDs: https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/#prerequisites
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    # TLSRoute (experimental)
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml",
  ]
}

module "talos_cluster" {
  source = "./resources/modules/talos-cluster"

  talos_version          = var.talos_version
  kubernetes_version     = var.kubernetes_version
  talos_config_path      = var.talos_config_path
  kubernetes_config_path = var.kubernetes_config_path
  talos_cluster_config   = local.talos_cluster_config
  machines               = local.machines
  bootstrap_charts       = local.bootstrap_charts
  on_destroy             = var.cluster_on_destroy
}
