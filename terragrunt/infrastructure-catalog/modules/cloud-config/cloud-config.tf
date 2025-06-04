resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = try(var.content_type, "snippets")
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_file {
    file_name = "user-data-cloud-config.yaml"
    path      = var.user_data_cloud_config
  }
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = try(var.content_type, "snippets")
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = "meta-data-cloud-config.yaml"
    data      = templatefile("${path.module}/meta-data-cloud-config.yaml.tftpl", {
      hostname : var.hostname,
      id : var.vm_id,
      providerID : "proxmox://${var.region}/${var.vm_id}",
      type : "${var.cpu}VCPU-${floor(var.memory / 1024)}GB",
      zone : var.zone,
      region : var.region,
    })
  }
}
