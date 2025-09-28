include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/cluster"
}

# Talos-cluster depends on the three VM directories created by this same stack
dependencies {
  paths = [
    "../control-plane-01",
    "../control-plane-02",
    "../control-plane-03",
  ]
}

# Pass everything through with the familiar "try(values…, fallback)" idiom
inputs = {
  # ---------- identification ----------
  cluster_name     = try(values.cluster_name)
  cluster_endpoint = try(values.cluster_endpoint)
  cluster_vip      = try(values.cluster_vip)

  # ---------- CIDRs ----------
  cluster_node_subnet    = try(values.cluster_node_subnet)
  cluster_pod_subnet     = try(values.cluster_pod_subnet)
  cluster_service_subnet = try(values.cluster_service_subnet)

  # ---------- versions ----------
  versions = try(values.versions)

  # ---------- Helm Charts ----------
  helm_charts = try(values.helm_charts)

  timeout = try(values.timeout, "10m")

  # machines map
  machines = jsonencode(values.machines)

  # destroy behavior
  cluster_on_destroy = try(values.cluster_on_destroy, {
    graceful = false
    reboot   = true
    reset    = true
  })

  # Tailscale configuration
  ts_authkey = try(values.ts_authkey)
}
