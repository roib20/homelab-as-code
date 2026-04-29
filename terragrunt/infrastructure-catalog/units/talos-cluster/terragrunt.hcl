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

  zswap = try(values.zswap, {
    enabled          = false
    max_pool_percent = 25
    shrinker_enabled = true
  })

  swap_disk_min = try(values.swap_disk_min, try(values.swap_disk, 0))
  swap_disk_max = try(values.swap_disk_max, try(values.swap_disk, 0))

  # machines map
  machines = jsonencode(values.machines)

  # Tailscale configuration
  ts_authkey = try(values.ts_authkey)
}
