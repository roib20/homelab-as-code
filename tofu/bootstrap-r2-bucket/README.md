# R2 Bootstrap - Pure OpenTofu

Simple OpenTofu module to create a Cloudflare R2 bucket for Terragrunt remote state storage.

## Usage

1. **Set environment variables:**
   ```bash
   export CLOUDFLARE_API_TOKEN="your-api-token"
   export CLOUDFLARE_ACCOUNT_ID="your-32-char-account-id"  
   export R2_BUCKET_NAME="homelab-terragrunt-state"  # optional
   export R2_LOCATION="apac"  # optional
   ```

2. **Initialize and apply:**
   ```bash
   cd tofu/bootstrap-r2
   tofu init
   tofu plan
   tofu apply
   ```

3. **Follow the output instructions** to create R2 credentials and configure Terragrunt.

## Variables

- `account_id` - Your Cloudflare Account ID (32-char hex string)
- `bucket_name` - R2 bucket name (default: "homelab-terragrunt-state")  
- `location` - R2 bucket location (default: "apac")

## Outputs

- `bucket_name` - Created bucket name
- `bucket_id` - Created bucket ID
- `r2_endpoint` - S3-compatible endpoint URL
- `next_steps` - Complete setup instructions

## Clean & Simple

- ✅ Pure OpenTofu - No Terragrunt complexity
- ✅ Local state - No circular dependencies
- ✅ Minimal configuration - Just creates the bucket
- ✅ Clear instructions - Shows exactly what to do next
