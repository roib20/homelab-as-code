locals {
  # Talos Image Factory URL generation
  talos_factory_url = local.platform_string != null ? "${local.factory_url}/image/${local.schematic_id}/${local.version}/${local.platform_string}.${local.file_extension}" : null
  talos_file_name   = local.platform_string != null ? "talos-${local.schematic_id}-${local.version}-${local.platform_string}.img" : null

  # Final URL and filename with fallbacks
  download_url       = var.url != null ? var.url : local.talos_factory_url
  download_file_name = var.url != null ? try(var.file_name, null) : local.talos_file_name
}

resource "proxmox_virtual_environment_download_file" "download" {
  for_each = toset(var.node_names)

  node_name = each.key # Required: Proxmox node name

  content_type = try(var.content_type, "iso") # Required: "iso" for VM images or "vztmpl" for LXC images
  datastore_id = var.datastore_id             # Required: Target datastore ID

  checksum                = try(var.checksum, null)                # Optional: Expected checksum of the file (nullable)
  checksum_algorithm      = try(var.checksum_algorithm, null)      # Optional: md5 | sha1 | sha224 | sha256 | sha384 | sha512
  decompression_algorithm = try(var.decompression_algorithm, null) # Optional: gz | xz | lzo | zst | bz2
  overwrite               = try(var.overwrite, false)              # Optional: Redownload if size differs
  overwrite_unmanaged     = try(var.overwrite_unmanaged, false)    # Optional: Delete and redownload if file exists and is unmanaged
  upload_timeout          = try(var.upload_timeout, 600)           # Optional: Timeout in seconds (default 600)
  verify                  = try(var.verify, true)

  url       = local.download_url       # Required: HTTP/HTTPS URL
  file_name = local.download_file_name # Optional: Filename override, especially for file extension issues
}
