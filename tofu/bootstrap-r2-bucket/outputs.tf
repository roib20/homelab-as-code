output "bucket_name" {
  description = "Name of the created R2 bucket"
  value       = cloudflare_r2_bucket.bucket.name
}

output "bucket_id" {
  description = "ID of the created R2 bucket"
  value       = cloudflare_r2_bucket.bucket.id
}

output "r2_endpoint" {
  description = "R2 S3-compatible endpoint URL"
  value       = "https://${var.account_id}.r2.cloudflarestorage.com"
}

output "eu_r2_endpoint" {
  description = "R2 S3-compatible endpoint URL"
  value       = "https://${var.account_id}.eu.r2.cloudflarestorage.com"
}

output "bucket_creation_date" {
  description = "Timestamp when the bucket was created."
  value       = cloudflare_r2_bucket.bucket.creation_date
}
