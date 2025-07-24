variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = null
  validation {
    condition     = var.account_id == null || can(regex("^[a-f0-9]{32}$", var.account_id))
    error_message = "Account ID must be a 32-character hexadecimal string."
  }
}

variable "bucket_name" {
  description = "Name of the R2 bucket"
  type        = string
  default     = "homelab-as-code"

  # Bucket naming limitations: https://developers.cloudflare.com/r2/buckets/create-buckets/#bucket-level-operations
  validation {
    condition     = var.bucket_name == null || (can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63)
    error_message = "Bucket name must be 3-63 characters, contain only lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }
}

variable "location" {
  description = "Bucket location region code. One of: apac, eeur, enam, weur, wnam, oc."
  type        = string
  default     = null

  validation {
    condition     = var.location == null || contains(["apac", "eeur", "enam", "weur", "wnam", "oc"], var.location)
    error_message = "location must be one of: apac, eeur, enam, weur, wnam, oc."
  }
}

variable "storage_class" {
  description = "Default storage class for new objects. One of: Standard, InfrequentAccess."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.storage_class == null || contains(["Standard", "InfrequentAccess"], var.storage_class)
    error_message = "storage_class must be either Standard or InfrequentAccess."
  }
}

variable "jurisdiction" {
  description = "Jurisdiction for data residency. One of: default, eu, fedramp."
  type        = string
  default     = "default"

  validation {
    condition     = var.jurisdiction == null || contains(["default", "eu", "fedramp"], var.jurisdiction)
    error_message = "jurisdiction must be one of: default, eu, fedramp."
  }
}
