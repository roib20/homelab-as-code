locals {
  # Environment, such as "prod" or "non-prod"
  environment = "non-prod"
  
  # Root "terragrunt/infrastructure-live" directory, containing "prod" and "non-prod" directories
  root_dir = "${dirname(find_in_parent_folders("root.hcl"))}"

  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${local.root_dir}/.."

  # Root "kubernetes" directory
  kubernetes_dir = "${local.root_dir}/../../kubernetes"
}

unit "bitwarden-access" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/bitwarden-secrets-manager"

  path = "bitwarden-access"

  values = {
    bws_access_token = get_env("BWS_ACCESS_TOKEN")
    secret_key       = "BWS_ACCESS_TOKEN"
    organization_id  = try(get_env("ORGANIZATION_ID"), null) 
  }
}

unit "kubernetes-manifests" {
  source = "${local.terragrunt_dir}/infrastructure-catalog/units/bootstrap-k8s-secrets"

  path = "kubernetes-manifests"

  values = {
    kubeconfig_path         = "~/.kube/config"
    manifest_yaml_files     = [
      "${local.kubernetes_dir}/cluster/addons/external-secrets/base/namespace.yaml",
      "${local.kubernetes_dir}/hidden-secrets/bitwarden-access-token.yaml.tftpl",
      "${local.kubernetes_dir}/hidden-secrets/bitwarden-secretsmanager.yaml.tftpl",
      "${local.kubernetes_dir}/cluster/argo/argocd/base/namespace.yaml",
      "${local.kubernetes_dir}/hidden-secrets/git-credentials.yaml.externalsecret",
    ]
  }
}
