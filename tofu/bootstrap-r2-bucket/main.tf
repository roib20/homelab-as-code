# Create R2 bucket for Terragrunt state storage
resource "cloudflare_r2_bucket" "bucket" {
  account_id    = var.account_id
  name          = var.bucket_name
  location      = try(upper(var.location), null)
  jurisdiction  = var.jurisdiction
  storage_class = var.storage_class
}
