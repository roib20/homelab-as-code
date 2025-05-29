# This completes when the cluster is ready to be upgraded.
resource "terraform_data" "talos_cluster_health" {
  depends_on = [talos_machine_bootstrap.this, talos_machine_configuration_apply.machines]
  for_each   = { for k, v in var.machines : k => v if yamldecode(v.talos_config) == "controlplane" }

  triggers_replace = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "talosctl --talosconfig $TALOSCONFIG health --nodes $NODE --wait-timeout $TIMEOUT"

    environment = {
      TALOSCONFIG = pathexpand(var.talos_config_path)
      NODE        = each.key
      TIMEOUT     = var.timeout
    }
  }
}

# This completes when the upgrade is complete.
resource "terraform_data" "talos_cluster_health_upgrade" {
  depends_on = [terraform_data.talos_upgrade_trigger]
  for_each   = { for k, v in var.machines : k => v if yamldecode(v.talos_config) == "controlplane" }

  triggers_replace = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "talosctl --talosconfig $TALOSCONFIG health --nodes $NODE --wait-timeout $TIMEOUT"

    environment = {
      TALOSCONFIG = pathexpand(var.talos_config_path)
      NODE        = each.key
      TIMEOUT     = var.timeout
    }
  }
}
