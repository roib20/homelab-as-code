variable "manifest_yaml_files" {
  description = "List of paths to Kubernetes manifest YAML files"
  type        = list(string)
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}
