locals {
  factory_url = "https://factory.talos.dev"

  platform       = try(var.talos_platform, null)
  arch           = try(var.talos_arch, null)
  version        = try("v${var.talos_version}", null)
  schematic_file = file("${path.module}/image/schematic.yaml")

  # Use talos_schematic_id value if provided, otherwise calculate it from a schematic file
  schematic_id = (
    var.talos_schematic_id != null && var.talos_schematic_id != ""
    ? var.talos_schematic_id
    : try(jsondecode(data.http.schematic_id.response_body)["id"], null)
  )
  image_id = try("${local.schematic_id}_${local.version}", null)

  # update_version = coalesce(var.image.update_version, var.image.version)
  # update_schematic = coalesce(var.image.update_schematic, var.image.schematic)
  # update_schematic_id = jsondecode(data.http.updated_schematic_id.response_body)["id"]
  # update_image_id = "${local.update_schematic_id}_${local.update_version}"
}

data "http" "schematic_id" {
  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic_file
}

# data "http" "updated_schematic_id" {
#   url          = "${var.image.factory_url}/schematics"
#   method       = "POST"
#   request_body = local.update_schematic
# }
