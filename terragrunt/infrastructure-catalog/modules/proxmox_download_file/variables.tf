# Required Variables

variable "content_type" {
  description = "The file content type. Must be 'iso' for VM images or 'vztmpl' for LXC images."
  type        = string
  default     = "iso"
}

variable "datastore_id" {
  description = "The identifier for the target datastore."
  type        = string
}

variable "node_names" {
  description = "List of Proxmox node names where the file will be stored."
  type        = list(string)
}

# Only set if not using Talos Image Factory
variable "url" {
  description = "The URL to download the file from. Must match regex: https?://.*."
  type        = string
  validation {
    condition     = var.url == null || can(regex("^https?://.*", var.url))
    error_message = "The URL must start with http:// or https://"
  }
  nullable = true
  default  = null
}

# Optional Variables

variable "checksum" {
  description = "The expected checksum of the file."
  type        = string
  nullable    = true
  default     = null
}

variable "checksum_algorithm" {
  description = "The algorithm used to calculate the checksum. Must be one of: `md5`, `sha1`, `sha224`, `sha256`, `sha384`, `sha512`."
  type        = string
  nullable    = true
  default     = null
  validation {
    condition     = var.checksum_algorithm != null ? contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], var.checksum_algorithm) : true
    error_message = "checksum_algorithm must be one of: md5, sha1, sha224, sha256, sha384, sha512."
  }
}

variable "decompression_algorithm" {
  description = "Decompress the downloaded file using this algorithm. Must be one of: `gz`, `lzo`, `zst`, `bz2`."
  type        = string
  nullable    = true
  default     = null
  validation {
    condition = (
      var.decompression_algorithm != null ? contains(["gz", "lzo", "zst", "bz2"], var.decompression_algorithm) : true
    )
    error_message = "decompression_algorithm must be one of: gz, lzo, zst, bz2."
  }
}

variable "file_name" {
  description = "The file name. If not provided, it is calculated using `url`. PVE will raise 'wrong file extension' error for some popular extensions file `.raw` or `.qcow2`. Workaround is to use e.g. `.img` instead."
  type        = string
  nullable    = true
  default     = null
}

variable "overwrite" {
  description = "If `true` and size of uploaded file is different, than size from url Content-Length header, file will be downloaded again. If `false`, there will be no checks."
  type        = bool
  default     = false
}

variable "overwrite_unmanaged" {
  description = "If `true` and a file with the same name already exists in the datastore, it will be deleted and the new file will be downloaded. If `false` and the file already exists, an error will be returned."
  type        = bool
  default     = false
}

variable "upload_timeout" {
  description = "The download timeout in seconds. Defaults to `600` (10 minutes)."
  type        = number
  default     = 600
}

variable "verify" {
  description = "Verify SSL/TLS certificates. Defaults to `true`."
  type        = bool
  default     = true
}

# Talos Image Factory Variables

variable "talos_platform" {
  type     = string
  nullable = true
  default  = null
}

variable "talos_arch" {
  type     = string
  nullable = true
  default  = null
}

variable "talos_version" {
  type     = string
  nullable = true
  default  = null
}

variable "talos_schematic_id" {
  type     = string
  nullable = true
  default  = null
}

variable "talos_secureboot" {
  description = "Enable SecureBoot for Talos images. When true, downloads secureboot-enabled ISO."
  type        = bool
  default     = false
}
