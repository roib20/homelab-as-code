# Dynamic Terragrunt Stack for Talos Kubernetes cluster on Proxmox

locals {
  # ─── Directory discovery ─────────────────────────────────────────────────────
  environment    = "prod"
  root_dir       = dirname(find_in_parent_folders("root.hcl"))
  terragrunt_dir = "${local.root_dir}/.."
  kubernetes_dir = "${local.root_dir}/../../kubernetes"

  # ─── Proxmox nodes configuration ─────────────────────────────────────────────
  node_vars  = read_terragrunt_config("${local.root_dir}/${local.environment}/multi-node/nodes.hcl")
  nodes      = local.node_vars.locals.nodes
  node_names = keys(local.nodes)

  # ─── Account variables ───────────────────────────────────────────────────────
  account_vars = read_terragrunt_config("${local.root_dir}/${local.environment}/account.hcl")

  # ─── Versions ────────────────────────────────────────────────────────────────
  versions = {
    kubernetes_version       = "1.34.0",
    initial_talos_version    = "1.11.1", # Do not change this value after initial deployment
    talos_version            = "1.11.1", # Change this value to safely upgrade the Talos version
    prometheus_version       = "17.0.2",
    external-secrets_version = "0.18.0",
  }

  # ─── Machines / IP layout ────────────────────────────────────────────────────
  controlplane_nodes = [
    {
      name      = "control-plane-01"
      ip        = "192.168.1.51"
      vm_id     = 1001
      cpu_cores = 3
      memory    = 14336
      node_name = local.node_names[0] # pve-node-01
    },
    {
      name      = "control-plane-02"
      ip        = "192.168.1.52"
      vm_id     = 1002
      cpu_cores = 3
      memory    = 14336
      node_name = local.node_names[1] # pve-node-02
    },
    {
      name      = "control-plane-03"
      ip        = "192.168.1.53"
      vm_id     = 1003
      cpu_cores = 3
      memory    = 14336
      node_name = local.node_names[2] # pve-node-03
    },
  ]

  worker_nodes = []

  talos_nodes = concat(local.controlplane_nodes, local.worker_nodes)

  machines = {
    for node in local.talos_nodes :
    node.name => {
      type = contains(local.controlplane_nodes, node) ? "controlplane" : "worker"

      install = {
        disk = "/dev/vda"
        extensions = [
          "siderolabs/i915",
          "siderolabs/intel-ucode",
          "siderolabs/iscsi-tools",
          "siderolabs/mei",
          "siderolabs/qemu-guest-agent",
          "siderolabs/tailscale",
          "siderolabs/util-linux-tools",
        ]
      }

      interfaces = [{
        addresses = [node.ip]
      }]

      hostname  = node.name
      vm_id     = node.vm_id
      region    = "${local.cluster_name}"
      zone      = node.node_name
      cpu_cores = node.cpu_cores
      memory    = node.memory
    }
  }

  cluster_name           = "talos"
  cluster_endpoint       = local.controlplane_nodes[0].ip
  cluster_vip            = "192.168.1.50"
  cluster_node_subnet    = "192.168.1.0/24"
  cluster_pod_subnet     = "10.244.0.0/16"
  cluster_service_subnet = "10.96.0.0/12"

  timeout = "10m"

  # Helm Charts
  helm_charts = {
    cilium = {
      chart_version   = "1.17.4"
      helm_repository = "oci://ghcr.io/home-operations/charts-mirror"
      values          = file("${local.kubernetes_dir}/cluster/active/addons/cilium/base/values.yaml")
    }
    talos-ccm = {
      chart_version   = "0.4.6"
      helm_repository = "oci://ghcr.io/siderolabs/charts"
      values          = file("${local.kubernetes_dir}/cluster/active/addons/talos-cloud-controller-manager/base/values.yaml")
    }
    cert-manager = {
      chart_version   = "1.18.0"
      helm_repository = "https://charts.jetstack.io"
      values          = file("${local.kubernetes_dir}/cluster/active/addons/cert-manager/base/values.yaml")
    }
    coredns = {
      chart_version   = "1.43.0"
      helm_repository = "oci://ghcr.io/coredns/charts"
      values          = file("${local.kubernetes_dir}/cluster/active/addons/coredns/base/values.yaml")
    }
    spegel = {
      chart_version   = "0.3.0"
      helm_repository = "oci://ghcr.io/spegel-org/helm-charts"
      values          = file("${local.kubernetes_dir}/cluster/active/addons/spegel/base/values.yaml")
    }
  }
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"
  path   = "download_file"

  values = {
    node_names     = local.node_names
    datastore_id   = "local"
    talos_version  = "${local.versions.initial_talos_version}"
    talos_platform = "nocloud"
    talos_arch     = "amd64"
  }
}

unit "cloud-config-$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[0].name}"

  values = {
    node_name              = "${local.controlplane_nodes[0].node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname = "${local.controlplane_nodes[0].name}"
    vm_id    = "${local.controlplane_nodes[0].vm_id}"
    region   = "${local.cluster_name}"
    zone     = "${local.controlplane_nodes[0].node_name}"
    cpu      = "${local.controlplane_nodes[0].cpu_cores}"
    memory   = "${local.controlplane_nodes[0].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[0].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[0].name}"

  values = {
    node_name    = "${local.controlplane_nodes[0].node_name}"
    vm_name      = "${local.controlplane_nodes[0].name}"
    ipv4_address = "${local.controlplane_nodes[0].ip}"

    hostname     = "${local.controlplane_nodes[0].name}"
    vm_id        = "${local.controlplane_nodes[0].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.controlplane_nodes[0].node_name}"
    cpu_cores    = "${local.controlplane_nodes[0].cpu_cores}"
    memory       = "${local.controlplane_nodes[0].memory}"
    disk_size_gb = 400

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[0].name}.yaml"
  }
}

unit "cloud-config-$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[1].name}"

  values = {
    node_name              = "${local.controlplane_nodes[1].node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname = "${local.controlplane_nodes[1].name}"
    vm_id    = "${local.controlplane_nodes[1].vm_id}"
    region   = "${local.cluster_name}"
    zone     = "${local.controlplane_nodes[1].node_name}"
    cpu      = "${local.controlplane_nodes[1].cpu_cores}"
    memory   = "${local.controlplane_nodes[1].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[1].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[1].name}"

  values = {
    node_name    = "${local.controlplane_nodes[1].node_name}"
    vm_name      = "${local.controlplane_nodes[1].name}"
    ipv4_address = "${local.controlplane_nodes[1].ip}"

    hostname     = "${local.controlplane_nodes[1].name}"
    vm_id        = "${local.controlplane_nodes[1].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.controlplane_nodes[1].node_name}"
    cpu_cores    = "${local.controlplane_nodes[1].cpu_cores}"
    memory       = "${local.controlplane_nodes[1].memory}"
    disk_size_gb = 400

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[1].name}.yaml"
  }
}

unit "cloud-config-$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[2].name}"

  values = {
    node_name              = "${local.controlplane_nodes[2].node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname = "${local.controlplane_nodes[2].name}"
    vm_id    = "${local.controlplane_nodes[2].vm_id}"
    region   = "${local.cluster_name}"
    zone     = "${local.controlplane_nodes[2].node_name}"
    cpu      = "${local.controlplane_nodes[2].cpu_cores}"
    memory   = "${local.controlplane_nodes[2].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[2].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[2].name}"

  values = {
    node_name    = "${local.controlplane_nodes[2].node_name}"
    vm_name      = "${local.controlplane_nodes[2].name}"
    ipv4_address = "${local.controlplane_nodes[2].ip}"

    hostname     = "${local.controlplane_nodes[2].name}"
    vm_id        = "${local.controlplane_nodes[2].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.controlplane_nodes[2].node_name}"
    cpu_cores    = "${local.controlplane_nodes[2].cpu_cores}"
    memory       = "${local.controlplane_nodes[2].memory}"
    disk_size_gb = 400

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[2].name}.yaml"
  }
}

unit "talos-cluster" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-cluster"
  path   = "talos-cluster"

  values = {
    # Cluster-wide settings
    cluster_name           = local.cluster_name
    cluster_endpoint       = local.cluster_endpoint
    cluster_vip            = local.cluster_vip
    cluster_node_subnet    = local.cluster_node_subnet
    cluster_pod_subnet     = local.cluster_pod_subnet
    cluster_service_subnet = local.cluster_service_subnet

    # Versions
    versions = local.versions

    # Helm Charts
    helm_charts = local.helm_charts

    # other locals
    timeout  = local.timeout
    machines = local.machines

    # Tailscale configuration
    ts_authkey = local.account_vars.locals.tailscale.ts_authkey
  }
}
