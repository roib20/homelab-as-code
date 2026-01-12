locals {
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/kubernetes-manifests"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  kubeconfig_path     = try(values.kubeconfig_path, "~/.kube/config")
  manifest_yaml_files = values.manifest_yaml_files
  secret_yaml_files   = try(values.secret_yaml_files, [])
  template_vars       = try(values.template_vars, {})
}
