variable "cluster_name" {
  description = "A name to provide for the cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the cluster."
  type        = string
}

variable "cluster_vip" {
  description = "The VIP to use for the Talos cluster. Applied to the first interface of control plane machines."
  type        = string
}

variable "cluster_node_subnet" {
  description = "The subnet to use for the Talos cluster nodes."
  type        = string
}

variable "cluster_pod_subnet" {
  description = "The pod subnet to use for pods on the Talos cluster."
  type        = string
  default     = "10.244.0.0/16"
}

variable "cluster_service_subnet" {
  description = "The pod subnet to use for services on the Talos cluster."
  type        = string
  default     = "10.96.0.0/12"
}

variable "cluster_on_destroy" {
  description = "How to perform node destruction"
  type = object({
    graceful = string
    reboot   = string
    reset    = string
  })
  default = {
    graceful = false
    reboot   = true
    reset    = true
  }
}

variable "cilium_helm_values" {
  description = "The path for `values.yaml` to use for the Cilium Helm chart."
  type        = string
}

variable "cilium_version" {
  description = "The version of Cilium to use."
  type        = string
}

variable "talos_ccm_helm_values" {
  description = "The path for `values.yaml` to use for the Talos CCM Helm chart."
  type        = string
}

variable "talos_ccm_version" {
  description = "The version of Talos CCM to use."
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use."
  type        = string
}

variable "talos_version" {
  description = "The version of Talos to use."
  type        = string
}

variable "prometheus_version" {
  description = "The version of Prometheus to use."
  type        = string
}

variable "nameservers" {
  description = "The nameservers to use for the cluster."
  type        = list(string)
}

variable "timeservers" {
  description = "The timeservers to use for the cluster."
  type        = list(string)
}

variable "talos_config_path" {
  description = "The path to output the Talos configuration file."
  type        = string
  default     = "~/.talos"
}

variable "kubernetes_config_path" {
  description = "The path to output the Kubernetes configuration file."
  type        = string
  default     = "~/.kube"
}

variable "machines" {
  description = "A map of machines to create the talos cluster from."
  type = map(object({
    type = string
    install = object({
      disk              = string
      extensions        = optional(list(string), [])
      extra_kernel_args = optional(list(string), [])
      secureboot        = optional(bool, false)
      architecture      = optional(string, "amd64")
      platform          = optional(string, "metal")
      sbc               = optional(string, "")
      wipe              = optional(bool, true)
    })
    labels = optional(list(object({
      key   = string
      value = string
    })), [])
    annotations = optional(list(object({
      key   = string
      value = string
    })), [])
    files = optional(list(object({
      path        = string
      op          = string
      permissions = string
      content     = string
    })), [])
    interfaces = list(object({
      addresses        = list(string)
      dhcp_routeMetric = optional(number, 100)
      vlans = optional(list(object({
        vlanId           = number
        addresses        = list(string)
        dhcp_routeMetric = optional(number, 100)
      })), [])
    }))
  }))
}
