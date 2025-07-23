#!/bin/sh

set -eu

# Source .env file if it exists
source_env() {
    # shellcheck disable=SC1091
    if [ -f ".env" ]; then
        set -a
        . "${PWD}/.env"
        set +a
        return 0
    fi
    return 1
}

# Helper function for hidden input
read_hidden() {
    printf "%s: " "$1"
    stty -echo
    read -r "$2"
    stty echo
    echo
}

# Validate Cloudflare API token
validate_token() {
    token="$1"
    account_id="$2"
    valid_string="This API Token is valid and active"

    printf "Validating token..."
    if curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$account_id/tokens/verify" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type:application/json" |
        grep -q "$valid_string"; then
        printf "\rValid Cloudflare API token\n"
        return 0
    else
        printf "\rInvalid Cloudflare API token.
For getting your token, see instructions here:
https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/#create-scoped-bucket-api-keys\n"
        return 1
    fi
}

# Run tofu format, validate, and apply
run_tofu_cycle() {
    tofu fmt --check
    tofu validate
    tofu apply -auto-approve
}

# Display setup instructions
show_instructions() {
    echo "
You will need to create a bucket scoped R2 API token with Object Read & Write permissions. To create an API token, do the following:

    1. In Account Home, select R2.
    2. Under Account details, select Manage R2 API tokens.
    3. Select Create API token ↗: https://dash.cloudflare.com/?to=/:account/r2/api-tokens
    4. Select the R2 Token text to edit your API token name.
    5. Under Permissions, select the Object Read and Write permissions, then scope your token to your <YOUR_BUCKET_NAME> bucket.
    6. Select Create API Token.

After your token has been successfully created, copy your values below."
    echo
}

# Setup terraform.tfvars and collect credentials
setup_tfvars() {
    # Create terraform.tfvars if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        echo "Get your Account ID from Account Home: https://dash.cloudflare.com"
        read_hidden "Enter your Cloudflare Account ID" ACCOUNT_ID
        # Insert account_id into terraform.tfvars
        cp "terraform.tfvars.example" "terraform.tfvars"
        sed -i "s/account_id = \"\"/account_id = \"$ACCOUNT_ID\"/" terraform.tfvars
    else
        # Extract ACCOUNT_ID from existing terraform.tfvars for token verification
        ACCOUNT_ID=$(grep '^account_id' terraform.tfvars | sed 's/account_id[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/')
        echo "Using Account ID from terraform.tfvars: $ACCOUNT_ID"
    fi
}

setup_env() {
    # Prompt for missing environment variables

    # Check for CLOUDFLARE_API_TOKEN
    if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
        valid_token=false
        while [ ${valid_token} = false ]
        do
            # Ask user to enter Cloudflare API token
            stty -echo
            printf "Enter Cloudflare API token: "
            read -r CLOUDFLARE_API_TOKEN
            stty echo
            printf "\n"

            if validate_token "$CLOUDFLARE_API_TOKEN" "$ACCOUNT_ID"; then
                valid_token=true
            fi
        done
        export CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN"
    else
        echo "Using Cloudflare API token from environment"
        if ! validate_token "$CLOUDFLARE_API_TOKEN" "$ACCOUNT_ID"; then
            echo "Environment token is invalid, please update .env file"
            exit 1
        fi
    fi

    # Check for AWS_ACCESS_KEY_ID
    if [ -z "${AWS_ACCESS_KEY_ID:-}" ]; then
        read_hidden "Enter your AWS Access Key ID" AWS_ACCESS_KEY_ID
        export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    else
        echo "Using AWS Access Key ID from environment"
    fi

    # Check for AWS_SECRET_ACCESS_KEY
    if [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; then
        read_hidden "Enter your AWS Secret Access Key" AWS_SECRET_ACCESS_KEY
        export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    else
        echo "Using AWS Secret Access Key from environment"
    fi
}

setup() {
    setup_tfvars
    if ! source_env; then
        show_instructions
    fi
    setup_env
}

# Run tofu commands
run_tofu_deployment() {
    tofu init
    tofu init
    run_tofu_cycle

    cp "backend.tf.example" "backend.tf"
    tofu init -reconfigure
    run_tofu_cycle
}

# Remove local state
remove_local_state() {
    echo "Cleaning up local state files..."
    rm -f terraform.tfstate terraform.tfstate.backup
    echo "Local state files removed"
}

# Destroy resources (migrate back to local state first)
destroy_resources() {
    echo "Migrating back to local state for destruction..."
    remove_local_state
    rm -f backend.tf
    tofu init -migrate-state

    echo "Manually empty bucket before proceeding: https://dash.cloudflare.com/?to=/:account/r2"
    tofu destroy
}

# Apply resources
apply() {
    setup
    run_tofu_deployment
    remove_local_state
}

# Main function
main() {
    # Check command line arguments
    if [ "${1:-}" = "destroy" ]; then
        setup
        destroy_resources
    else
        apply
    fi
}

main "$@"
