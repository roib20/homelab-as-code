locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/cluster"
}

# Optional: pull in shared provider / backend settings
include "common" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/common.hcl"
  expose = true
}

# Talos-cluster depends on the three VM directories created by this same stack
dependencies {
  paths = [
            "../control-plane-01",
            "../control-plane-02",
            "../control-plane-03",
          ]
}

# Pass everything through with the familiar “try(values…, fallback)” idiom
inputs = {
  # ---------- identification ----------
  nodes                  = try(values.nodes, ["pve"])
  cluster_name           = try(values.cluster_name)
  cluster_endpoint       = try(values.cluster_endpoint)
  cluster_vip            = try(values.cluster_vip)

  # ---------- CIDRs ----------
  cluster_node_subnet    = try(values.cluster_node_subnet)
  cluster_pod_subnet     = try(values.cluster_pod_subnet)
  cluster_service_subnet = try(values.cluster_service_subnet)

  # ---------- versions ----------
  kubernetes_version     = try(values.kubernetes_version)
  talos_version          = try(values.talos_version)
  flux_version           = try(values.flux_version)
  prometheus_version     = try(values.prometheus_version)
  cilium_version         = try(values.cilium_version)
  talos_ccm_version      = try(values.talos_ccm_version)

  # ---------- misc ----------
  cilium_helm_values     = try(values.cilium_helm_values)
  talos_ccm_helm_values  = try(values.talos_ccm_helm_values)
  timeout                = try(values.timeout, "10m")

  # machines map
  machines               = jsonencode(values.machines)
}
