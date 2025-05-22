resource "proxmox_virtual_environment_download_file" "download" {
  content_type            = try(var.content_type, "iso")         # Required: "iso" for VM images or "vztmpl" for LXC images
  datastore_id            = var.datastore_id                     # Required: Target datastore ID
  node_name               = var.node_name                        # Required: Proxmox node name
  url                     = var.url                              # Required: HTTP/HTTPS URL

  checksum                = try(var.checksum)                    # Optional: Expected checksum of the file (nullable)
  checksum_algorithm      = try(var.checksum_algorithm)          # Optional: md5 | sha1 | sha224 | sha256 | sha384 | sha512
  decompression_algorithm = try(var.decompression_algorithm)     # Optional: gz | lzo | zst | bz2
  file_name               = try(var.file_name)                   # Optional: Filename override, especially for file extension issues
  overwrite               = try(var.overwrite, false)            # Optional: Redownload if size differs
  overwrite_unmanaged     = try(var.overwrite_unmanaged, false)  # Optional: Delete and redownload if file exists and is unmanaged
  upload_timeout          = try(var.upload_timeout, 600)         # Optional: Timeout in seconds (default 600)
  verify                  = try(var.verify, true)                # Optional: Verify SSL/TLS (default true)
}
