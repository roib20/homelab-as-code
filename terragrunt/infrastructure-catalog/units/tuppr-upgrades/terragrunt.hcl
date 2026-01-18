locals {
  terragrunt_dir = "${dirname(find_in_parent_folders("root.hcl"))}/.."
}

terraform {
  source = "${local.terragrunt_dir}/infrastructure-catalog/modules/kubernetes-manifests"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos-cluster" {
  config_path = "../talos-cluster"

  mock_outputs = {
    kubeconfig_filename = "~/.kube/config"
  }
}

inputs = {
  kubeconfig_path     = try(dependency.talos-cluster.outputs.kubeconfig_filename, "~/.kube/config")
  manifest_yaml_files = values.manifest_yaml_files
  secret_yaml_files   = try(values.secret_yaml_files, [])
  template_vars       = try(values.template_vars, {})
}
