locals {
  jurisdiction_subdomain = (
    var.jurisdiction == null || var.jurisdiction == "default"
    ? ""
    : ".${var.jurisdiction}"
  )
}

output "bucket_name" {
  description = "Name of the created R2 bucket"
  value       = cloudflare_r2_bucket.bucket.name
}

output "bucket_id" {
  description = "ID of the created R2 bucket"
  value       = cloudflare_r2_bucket.bucket.id
}

output "bucket_jurisdiction" {
  description = "Jurisdiction of the created R2 bucket"
  value       = var.jurisdiction
}

output "r2_endpoint" {
  description = "R2 S3-compatible endpoint URL based on jurisdiction"
  value       = "https://${var.account_id}${local.jurisdiction_subdomain}.r2.cloudflarestorage.com"
}

output "bucket_creation_date" {
  description = "Timestamp when the bucket was created."
  value       = cloudflare_r2_bucket.bucket.creation_date
}
