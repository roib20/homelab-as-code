# data "talos_cluster_health" "health" {
#   depends_on           = [ talos_machine_configuration_apply.controlplane, talos_machine_configuration_apply.worker ]
#   client_configuration = talos_machine_secrets.this.client_configuration
#   control_plane_nodes  = [for k, v in var.node_data.controlplanes : k]
#   worker_nodes         = try([for k, v in var.node_data.workers : k], null)
#   endpoints            = [for k, v in var.node_data.controlplanes : k]
#   timeouts = {
#     read = "10m"
#   }
# }
