locals {
  factory_url = "https://factory.talos.dev"

  platform = try(var.talos_platform, null)
  arch     = try(var.talos_arch, null)
  version  = try(var.talos_version, null)
  schematic = file("${path.module}/image/schematic.yaml")

  # schematic_id = try(try(var.talos_schematic_id, jsondecode(data.http.schematic_id.response_body)["id"]), null)
  schematic_id = try(jsondecode(data.http.schematic_id.response_body)["id"], null)
  image_id     = try("${local.schematic_id}_${local.version}", null)
}

data "http" "schematic_id" {
  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic
}

resource "proxmox_virtual_environment_download_file" "download" {
  depends_on              = [ data.http.schematic_id ]
  content_type            = try(var.content_type, "iso")               # Required: "iso" for VM images or "vztmpl" for LXC images
  datastore_id            = var.datastore_id                           # Required: Target datastore ID
  node_name               = var.node_name                              # Required: Proxmox node name
  # url                     = var.url                                    # Required: HTTP/HTTPS URL

  checksum                = try(var.checksum, null)                    # Optional: Expected checksum of the file (nullable)
  checksum_algorithm      = try(var.checksum_algorithm, null)          # Optional: md5 | sha1 | sha224 | sha256 | sha384 | sha512
  decompression_algorithm = try(var.decompression_algorithm, null)     # Optional: gz | lzo | zst | bz2
  # file_name               = try(var.file_name, null)                   # Optional: Filename override, especially for file extension issues
  overwrite               = try(var.overwrite, false)                  # Optional: Redownload if size differs
  overwrite_unmanaged     = try(var.overwrite_unmanaged, false)        # Optional: Delete and redownload if file exists and is unmanaged
  upload_timeout          = try(var.upload_timeout, 600)               # Optional: Timeout in seconds (default 600)
  verify                  = try(var.verify, true)
  
  url       = try("${local.factory_url}/image/${local.schematic_id}/${local.version}/${local.platform}-${local.arch}.iso", var.url)   # Required: HTTP/HTTPS URL
  file_name = try("talos-${local.schematic_id}-${local.version}-${local.platform}-${local.arch}.img", null)                           # Optional: Filename override, especially for file extension issues
}
