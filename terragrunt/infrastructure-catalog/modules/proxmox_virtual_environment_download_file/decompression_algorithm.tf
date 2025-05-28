locals {
  decompression_algorithm = try(var.decompression_algorithm, null)
  file_extension = (
    local.decompression_algorithm == "gz" ? "raw.gz" :
    local.decompression_algorithm == "xz" ? "raw.xz" :
    "iso"
  )
}
