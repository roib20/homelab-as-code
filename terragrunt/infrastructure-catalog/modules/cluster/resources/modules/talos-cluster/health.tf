# This completes when the cluster is ready to be upgraded.
resource "terraform_data" "talos_cluster_health" {
  depends_on = [talos_machine_bootstrap.this, talos_machine_configuration_apply.machines, local_sensitive_file.talosconfig]
  for_each   = { for v in var.machines : v.hostname => v if yamldecode(v.talos_config).type == "controlplane" }

  triggers_replace = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = length(local.worker_ips) > 0 ? (
      "talosctl --talosconfig \"$${TALOSCONFIG}\" health --nodes \"$${NODE}\" --control-plane-nodes \"$${CONTROL_PLANE_NODES}\" --worker-nodes \"$${WORKER_NODES}\" --endpoints \"$${NODE}\" --server=false --wait-timeout \"$${TIMEOUT}\""
      ) : (
      "talosctl --talosconfig \"$${TALOSCONFIG}\" health --nodes \"$${NODE}\" --control-plane-nodes \"$${CONTROL_PLANE_NODES}\" --endpoints \"$${NODE}\" --server=false --wait-timeout \"$${TIMEOUT}\""
    )

    environment = {
      TALOSCONFIG         = pathexpand("${var.talos_config_path}/config")
      NODE                = split("/", each.value.primary_ip)[0]
      CONTROL_PLANE_NODES = join(",", local.controlplane_ips)
      WORKER_NODES        = join(",", local.worker_ips)
      TIMEOUT             = var.timeout
    }
  }
}
