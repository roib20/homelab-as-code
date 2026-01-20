# This completes when the cluster is ready to be upgraded.
resource "terraform_data" "talos_cluster_health" {
  depends_on = [talos_machine_bootstrap.this, talos_machine_configuration_apply.machines, local_sensitive_file.talosconfig]
  for_each   = { for k, v in var.machines : yamldecode(v.talos_config).network.hostname => v if yamldecode(v.talos_config).type == "controlplane" }

  triggers_replace = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "talosctl --talosconfig $TALOSCONFIG health --nodes $NODE --wait-timeout $TIMEOUT"

    environment = {
      TALOSCONFIG = pathexpand("${var.talos_config_path}/config")
      NODE        = split("/", yamldecode(each.value.talos_config).network.interfaces[0].addresses[0])[0]
      TIMEOUT     = var.timeout
    }
  }
}
