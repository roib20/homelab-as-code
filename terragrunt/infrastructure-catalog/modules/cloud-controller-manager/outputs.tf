output "user_data_cloud_config" {
  value       = "${var.datastore_id}:${var.content_type}/user-data-cloud-config.yaml"
}

output "meta_data_cloud_config" {
  value       = "${var.datastore_id}:${var.content_type}/meta-data-cloud-config.yaml"
}

output "vendor_data_cloud_config" {
  value       = "${var.datastore_id}:${var.content_type}/vendor-data-cloud-config.yaml"
}

output "user_data_file_id" {
  value = proxmox_virtual_environment_file.user_data_cloud_config.id
}

output "meta_data_file_id" {
  value = proxmox_virtual_environment_file.meta_data_cloud_config.id
}

# output "vendor_data_file_id" {
#   value = proxmox_virtual_environment_file.vendor_data_cloud_config.id
# }
