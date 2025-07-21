output "user_data_cloud_config" {
  value = "${var.datastore_id}:${var.content_type}/user-data-cloud-config.yaml"
}

output "meta_data_cloud_config" {
  value = "${var.datastore_id}:${var.content_type}/meta-data-cloud-config.yaml"
}

output "vendor_data_cloud_config" {
  value = "${var.datastore_id}:${var.content_type}/vendor-data-cloud-config.yaml"
}