output "downloaded_file_id" {
  description = "(String) The unique identifier of the downloaded file resource."
  value       = proxmox_virtual_environment_download_file.download.id
}

output "downloaded_file_size" {
  description = "(Number) The file size."
  value       = proxmox_virtual_environment_download_file.download.size
}
