# Dynamic Terragrunt Stack for Talos Kubernetes cluster on Proxmox

locals {
  # ─── Directory discovery ─────────────────────────────────────────────────────
  environment    = "non-prod"
  root_dir       = dirname(find_in_parent_folders("root.hcl"))
  terragrunt_dir = "${local.root_dir}/.."
  kubernetes_dir = "${local.root_dir}/../../kubernetes"

  # ─── Proxmox node that will host the VMs ─────────────────────────────────────
  node_vars  = read_terragrunt_config("${local.root_dir}/${local.environment}/pve/node.hcl")
  node_name  = local.node_vars.locals.node_name

  # ─── Versions ────────────────────────────────────────────────────────────────
  talos_version       = "v1.10.3"
  kubernetes_version  = "v1.33.1"
  flux_version        = "v2.6.0"
  prometheus_version  = "17.0.2"
  cilium_version      = "1.17.4"
  talos_ccm_version   = "0.4.6"

  # ─── Machines / IP layout ────────────────────────────────────────────────────
  controlplane_nodes = [
    {
      name          = "control-plane-01"
      ip            = "192.168.1.51"
      vm_id         = 1001
      cpu_cores     = 2
      memory        = 4096
    },
    {
      name         = "control-plane-02"
      ip           = "192.168.1.52"
      vm_id        = 1002
      cpu_cores    = 2
      memory       = 4096
    },
    {
      name         = "control-plane-03"
      ip           = "192.168.1.53"
      vm_id        = 1003
      cpu_cores    = 2
      memory       = 4096
    },
  ]

  worker_nodes = []

  machines = {
    for node in concat(local.controlplane_nodes, local.worker_nodes) :
    node.name => {
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

      interfaces = [{
        addresses = [node.ip]
      }]

      hostname  = node.name
      vm_id     = node.vm_id
      region    = "${local.cluster_name}"
      zone      = local.node_name
      cpu_cores = node.cpu_cores
      memory    = node.memory
    }
  }

  cluster_name            = "talos"
  cluster_endpoint        = local.controlplane_nodes[0].ip
  cluster_vip             = "192.168.1.60"
  cluster_node_subnet     = "192.168.1.0/24"
  cluster_pod_subnet      = "10.244.0.0/16"
  cluster_service_subnet  = "10.96.0.0/12"

  cilium_helm_values    = file("${local.kubernetes_dir}/cluster/addons/cilium/base/values.yaml")
  talos_ccm_helm_values = file("${local.kubernetes_dir}/cluster/addons/talos-cloud-controller-manager/base/values.yaml")
  
  timeout               = "10m"
}

unit "download_file" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/proxmox_virtual_environment_download_file"
  path   = "download_file"

  values = {
    nodes          = ["${local.node_name}"]
    datastore_id   = "local"
    talos_version  = "${local.talos_version}"
    talos_platform = "nocloud"
    talos_arch     = "amd64"
  }
}

unit "cloud-config-$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[0].name}"

  values = {
    node_name              = "${local.node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname               = "${local.controlplane_nodes[0].name}"
    vm_id                  = "${local.controlplane_nodes[0].vm_id}"
    region                 = "${local.cluster_name}"
    zone                   = "${local.node_name}"
    cpu                    = "${local.controlplane_nodes[0].cpu_cores}"
    memory                 = "${local.controlplane_nodes[0].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[0].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[0].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[0].name}"

  values = {
    node_name    = "${local.node_name}"
    vm_name      = "${local.controlplane_nodes[0].name}"
    ipv4_address = "${local.controlplane_nodes[0].ip}"

    hostname     = "${local.controlplane_nodes[0].name}"
    vm_id        = "${local.controlplane_nodes[0].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.node_name}"
    cpu_cores    = "${local.controlplane_nodes[0].cpu_cores}"
    memory       = "${local.controlplane_nodes[0].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[0].name}.yaml"
  }
}

unit "cloud-config-$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[1].name}"

  values = {
    node_name              = "${local.node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname               = "${local.controlplane_nodes[1].name}"
    vm_id                  = "${local.controlplane_nodes[1].vm_id}"
    region                 = "${local.cluster_name}"
    zone                   = "${local.node_name}"
    cpu                    = "${local.controlplane_nodes[1].cpu_cores}"
    memory                 = "${local.controlplane_nodes[1].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[1].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[1].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[1].name}"

  values = {
    node_name    = "${local.node_name}"
    vm_name      = "${local.controlplane_nodes[1].name}"
    ipv4_address = "${local.controlplane_nodes[1].ip}"

    hostname     = "${local.controlplane_nodes[1].name}"
    vm_id        = "${local.controlplane_nodes[1].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.node_name}"
    cpu_cores    = "${local.controlplane_nodes[1].cpu_cores}"
    memory       = "${local.controlplane_nodes[1].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[1].name}.yaml"
  }
}

unit "cloud-config-$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/cloud-controller-manager"
  path   = "cloud-config/${local.controlplane_nodes[2].name}"

  values = {
    node_name              = "${local.node_name}"
    datastore_id           = "local"
    user_data_cloud_config = "${get_terragrunt_dir()}/user-data-cloud-config.yaml"

    hostname               = "${local.controlplane_nodes[2].name}"
    vm_id                  = "${local.controlplane_nodes[2].vm_id}"
    region                 = "${local.cluster_name}"
    zone                   = "${local.node_name}"
    cpu                    = "${local.controlplane_nodes[2].cpu_cores}"
    memory                 = "${local.controlplane_nodes[2].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[2].name}.yaml"
  }
}

unit "$${local.controlplane_nodes[2].name}" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-vm"
  path   = "${local.controlplane_nodes[2].name}"

  values = {
    node_name    = "${local.node_name}"
    vm_name      = "${local.controlplane_nodes[2].name}"
    ipv4_address = "${local.controlplane_nodes[2].ip}"

    hostname     = "${local.controlplane_nodes[2].name}"
    vm_id        = "${local.controlplane_nodes[2].vm_id}"
    region       = "${local.cluster_name}"
    zone         = "${local.node_name}"
    cpu_cores    = "${local.controlplane_nodes[2].cpu_cores}"
    memory       = "${local.controlplane_nodes[2].memory}"

    meta_data_cloud_config_file_name = "meta-data-cloud-config_${local.controlplane_nodes[2].name}.yaml"
  }
}

unit "talos-cluster" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/talos-cluster"
  path   = "talos-cluster"

  values = {
    nodes                  = [local.node_name]
    cluster_name           = local.cluster_name
    cluster_endpoint       = local.cluster_endpoint
    cluster_vip            = local.cluster_vip
    cluster_node_subnet    = local.cluster_node_subnet
    cluster_pod_subnet     = local.cluster_pod_subnet
    cluster_service_subnet = local.cluster_service_subnet

    kubernetes_version     = local.kubernetes_version
    talos_version          = local.talos_version
    flux_version           = local.flux_version
    prometheus_version     = local.prometheus_version
    cilium_version         = local.cilium_version
    cilium_helm_values     = local.cilium_helm_values
    talos_ccm_version      = local.talos_ccm_version
    talos_ccm_helm_values  = local.talos_ccm_helm_values

    timeout   = local.timeout
    machines  = local.machines
  }
}
