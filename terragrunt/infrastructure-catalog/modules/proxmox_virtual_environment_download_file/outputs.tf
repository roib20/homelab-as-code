output "downloaded_file_id" {
  description = "(String) The unique identifier of the downloaded file resource."
  value       = values(proxmox_virtual_environment_download_file.download)[0].id
}

output "downloaded_file_size" {
  description = "(Number) The file size."
  value       = values(proxmox_virtual_environment_download_file.download)[0].size
}

output "downloaded_file_ids" {
  description = "(Map) IDs of downloaded files, keyed by each node/image combination"
  value = {
    for resource_key, file in proxmox_virtual_environment_download_file.download :
    resource_key => file.id
  }
}

output "downloaded_file_sizes" {
  description = "(Map) Sizes of downloaded files, keyed by each node/image combination"
  value = {
    for resource_key, file in proxmox_virtual_environment_download_file.download :
    resource_key => file.size
  }
}
