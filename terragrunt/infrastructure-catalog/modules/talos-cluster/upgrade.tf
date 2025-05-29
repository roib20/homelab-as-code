# Hack: https://github.com/siderolabs/terraform-provider-talos/issues/140
# This upgrades the cluster
resource "terraform_data" "talos_upgrade_trigger" {
  depends_on = [terraform_data.talos_cluster_health]
  for_each   = local.machines

  triggers_replace = {
    desired_talos_tag    = local.machine_talos_version[each.key]
    desired_schematic_id = local.machine_schematic_id[each.key]
  }

  # Should only upgrade if there's a schematic mismatch
  provisioner "local-exec" {
    command = "flock $LOCK_FILE --command ${path.module}/resources/scripts/upgrade-node.sh"

    environment = {
      LOCK_FILE = "${path.module}/resources/.upgrade-node.lock"

      DESIRED_TALOS_TAG       = self.triggers_replace.desired_talos_tag
      DESIRED_TALOS_SCHEMATIC = self.triggers_replace.desired_schematic_id
      TALOS_CONFIG_PATH       = local_sensitive_file.talosconfig.filename
      TALOS_NODE              = split("/", yamldecode(each.value.talos_config).network.interfaces[0].addresses[0])[0] #each.key
      TIMEOUT                 = var.timeout
    }
  }
}
