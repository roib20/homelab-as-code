resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = try(var.content_type, "snippets")
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_file {
    path      = var.user_data_cloud_config
    file_name = "user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = try(var.content_type, "snippets")
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data      = templatefile("${path.module}/meta-data-cloud-config.yaml.tftpl", {
      hostname      = var.hostname
      vm_id         = var.vm_id
      instance_type = var.instance_type
      cluster_name  = var.cluster_name
      zone          = var.zone
    })
    file_name = "meta-data-cloud-config.yaml"
  }
}
