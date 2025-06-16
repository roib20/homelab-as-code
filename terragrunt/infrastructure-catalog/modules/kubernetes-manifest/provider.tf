provider "kubernetes" {
  # Use the kubeconfig file path
  config_path = var.kubeconfig_path
}
