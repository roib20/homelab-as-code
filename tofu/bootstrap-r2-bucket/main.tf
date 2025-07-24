# Create R2 bucket for Terragrunt state storage
resource "cloudflare_r2_bucket" "bucket" {
  account_id    = var.account_id
  name          = var.bucket_name
  location      = var.location
  jurisdiction  = var.jurisdiction
  storage_class = var.storage_class
}
