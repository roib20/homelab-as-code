variable "manifest_yaml_files" {
  description = "List of paths to Kubernetes manifest YAML files"
  type        = list(string)
}

variable "secret_yaml_files" {
  description = "List of secret manifest template paths to apply via kubernetes_secret"
  type        = list(string)
  default     = []
}

variable "template_vars" {
  description = "Optional map of variables to substitute in template manifests"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}
