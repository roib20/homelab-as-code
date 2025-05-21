resource "talos_machine_secrets" "machine_secrets" {}

data "talos_machine_configuration" "talos_machine_config" {
  cluster_name     = var.cluster_name
  machine_type     = var.talos_machine_type
  cluster_endpoint = "https://${var.ipv4_address}:6443"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

data "talos_client_configuration" "talos_client_config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  nodes                = [var.ipv4_address]
}

resource "talos_machine_configuration_apply" "config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_vm ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_machine_config.machine_configuration
  node                        = var.ipv4_address
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.config_apply ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.ipv4_address
}

data "talos_cluster_health" "health" {
  depends_on           = [ talos_machine_configuration_apply.config_apply ]
  client_configuration = data.talos_client_configuration.talos_client_config.client_configuration
  control_plane_nodes  = [ var.ipv4_address ]
  endpoints            = data.talos_client_configuration.talos_client_config.nodes
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.ipv4_address
}

output "talosconfig" {
  value = data.talos_client_configuration.talos_client_config.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
