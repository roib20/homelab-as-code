locals {
  # Root "terragrunt" directory, containing "infrastructure-catalog" and "infrastructure-live" directories
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/kubernetes-manifests"
}

dependency "bitwarden-access" {
  config_path = "../bitwarden-access"

  # Let ‘terragrunt plan’ succeed before the first real apply:
  mock_outputs = {
    secret_value_base64 = ""
    organization_id     = ""
    project_id          = ""
  }
}

inputs = {
  kubeconfig_path     = try(values.kubeconfig_path, "~/.kube/config")
  manifest_yaml_files = values.manifest_yaml_files
  secret_yaml_files   = try(values.secret_yaml_files, [])

  template_vars = try(values.template_vars, {
    BWS_ACCESS_TOKEN = dependency.bitwarden-access.outputs.secret_value_base64
    organizationID   = dependency.bitwarden-access.outputs.organization_id
    projectID        = dependency.bitwarden-access.outputs.project_id
  })
}
