resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = try(var.content_type, "snippets")
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_file {
    path      = var.user_data_cloud_config
    file_name = "user-data-cloud-config.yaml"
  }
}
