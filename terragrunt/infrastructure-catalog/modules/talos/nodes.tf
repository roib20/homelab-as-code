locals {
    controlplane_nodes = [for k, v in var.node_data.controlplanes : k]
    worker_nodes       = [for k, v in var.node_data.workers : k]
    all_nodes          = concat(local.controlplane_nodes, local.worker_nodes)
}