locals {
  # ─── Directory discovery ─────────────────────────────────────────────────────
  environment    = "non-prod"
  root_dir       = dirname(find_in_parent_folders("root.hcl"))
  terragrunt_dir = "${local.root_dir}/.."

  # ─── Proxmox node that will host the VMs ─────────────────────────────────────
  node_vars  = read_terragrunt_config("${local.root_dir}/${local.environment}/pve/node.hcl")
  node_name  = local.node_vars.locals.node_name

  # ─── Versions ────────────────────────────────────────────────────────────────
  talos_version       = "v1.10.3"
  kubernetes_version  = "v1.33.1"
  flux_version        = "v2.6.0"
  prometheus_version  = "17.0.2"
  cilium_version      = "1.17.4"

  # ─── Machines / IP layout ────────────────────────────────────────────────────
  controlplane_nodes = [
    { 
      name = "talos-control-plane-01", 
      ip = "192.168.1.51"
    },
    { 
      name = "talos-control-plane-02", 
      ip = "192.168.1.52"
    },
    { 
      name = "talos-control-plane-03", 
      ip = "192.168.1.53"
    },
  ]

  worker_nodes = []

  # Build the map the **cluster** unit expects
  machines = {
    for index, node in concat(local.controlplane_nodes, local.worker_nodes) :
    "node${idx+1}" => {
      type = contains(local.controlplane_nodes, node) ? "controlplane" : "worker"

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

      interfaces = [{ addresses = [node.ip] }]
    }
  }

  # ─── Cluster-wide networking ─────────────────────────────────────────────────
  cluster_name            = "talos"
  cluster_endpoint        = local.controlplane_nodes[0].ip   # 192.168.1.51
  cluster_vip             = "192.168.1.60"
  cluster_node_subnet     = "192.168.1.0/24"
  cluster_pod_subnet      = "10.244.0.0/16"
  cluster_service_subnet  = "10.96.0.0/12"

  # Extra files / timeouts
  cilium_helm_values = file("${local.terragrunt_dir}/infrastructure-live/non-prod/kubernetes/manifests/helm-release/cilium/values.yaml")
  timeout            = "10m"
}

# ─── Shared artefact download (raw Talos image) ────────────────────────────────
unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"
  path   = "download_file"

  values = {
    nodes                = ["${local.node_name}"]
    datastore_id         = "local"
    talos_version        = "${local.talos_version}"
    talos_platform       = "nocloud"
    talos_arch           = "amd64"
  }
}

# ─── One VM unit per control-plane node ────────────────────────────────────────
# (copy-paste & alter if you add workers later)
unit "$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = local.controlplane_nodes[0].name
  values = {
    node_name    = local.node_name
    vm_name      = local.controlplane_nodes[0].name
    ipv4_address = local.controlplane_nodes[0].ip
  }
}

unit "$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = local.controlplane_nodes[1].name
  values = {
    node_name    = local.node_name
    vm_name      = local.controlplane_nodes[1].name
    ipv4_address = local.controlplane_nodes[1].ip
  }
}

unit "$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = local.controlplane_nodes[2].name
  values = {
    node_name    = local.node_name
    vm_name      = local.controlplane_nodes[2].name
    ipv4_address = local.controlplane_nodes[2].ip
  }
}

# ─── The cluster itself (generates the Talos manifests) ────────────────────────
unit "talos-cluster" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-cluster"
  path   = "talos-cluster"

  values = {
    nodes                  = ["${local.node_name}"]

    # cluster id / addressing
    cluster_name           = local.cluster_name
    cluster_endpoint       = local.cluster_endpoint
    cluster_vip            = local.cluster_vip
    cluster_node_subnet    = local.cluster_node_subnet
    cluster_pod_subnet     = local.cluster_pod_subnet
    cluster_service_subnet = local.cluster_service_subnet

    # versions
    kubernetes_version     = local.kubernetes_version
    talos_version          = local.talos_version
    flux_version           = local.flux_version
    prometheus_version     = local.prometheus_version
    cilium_version         = local.cilium_version
    cilium_helm_values     = local.cilium_helm_values

    # misc
    timeout   = local.timeout
    machines  = local.machines
  }
}
