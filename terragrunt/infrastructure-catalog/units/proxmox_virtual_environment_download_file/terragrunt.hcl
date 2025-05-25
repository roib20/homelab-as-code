include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/proxmox_virtual_environment_download_file"
}

inputs = {
  content_type            = try(values.content_type, "iso")         # Required: "iso" for VM images or "vztmpl" for LXC images
  datastore_id            = values.datastore_id                     # Required: Target datastore ID
  node_name               = values.node_name                        # Required: Proxmox node name
  url                     = values.url                              # Required: HTTP/HTTPS URL

  checksum                = try(values.checksum, null)                    # Optional: Expected checksum of the file (nullable)
  checksum_algorithm      = try(values.checksum_algorithm, null)          # Optional: md5 | sha1 | sha224 | sha256 | sha384 | sha512
  decompression_algorithm = try(values.decompression_algorithm, null)     # Optional: gz | lzo | zst | bz2
  file_name               = try(values.file_name, null)                   # Optional: Filename override, especially for file extension issues
  overwrite               = try(values.overwrite, false)            # Optional: Redownload if size differs
  overwrite_unmanaged     = try(values.overwrite_unmanaged, false)  # Optional: Delete and redownload if file exists and is unmanaged
  upload_timeout          = try(values.upload_timeout, 600)         # Optional: Timeout in seconds (default 600)
  verify                  = try(values.verify, true)                # Optional: Verify SSL/TLS (default true)
}
