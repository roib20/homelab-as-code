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
    graceful = bool
    reboot   = bool
    reset    = bool
  })
  default = {
    graceful = false
    reboot   = true
    reset    = true
  }
}

variable "zswap" {
  description = "Zswap configuration for Talos nodes."
  type = object({
    enabled          = bool
    max_pool_percent = number
    shrinker_enabled = bool
  })
  default = {
    enabled          = false
    max_pool_percent = 25
    shrinker_enabled = true
  }

  validation {
    condition     = var.zswap.max_pool_percent >= 0 && var.zswap.max_pool_percent <= 100
    error_message = "zswap.max_pool_percent must be between 0 and 100."
  }
}

variable "swap_disk" {
  description = "Swap disk size in GB for Talos VM swap backing disk."
  type        = number
  default     = 0

  validation {
    condition     = var.zswap.enabled ? var.swap_disk > 0 : var.swap_disk >= 0
    error_message = "swap_disk must be non-negative, and greater than 0 when zswap.enabled is true."
  }
}

variable "helm_charts" {
  description = "Configuration for each Helm chart: values, chart, release name, namespace, version, and repository."
  type = map(object({
    values          = string # Helm values
    chart           = string # chart name
    name            = string # release name
    namespace       = string # release namespace
    chart_version   = string # version of the chart
    helm_repository = string # repository URL or name
  }))
}

variable "versions" {
  type = object({
    kubernetes_version       = string # The version of Kubernetes to use.
    talos_version            = string # The version of Talos to use.
    external-secrets_version = string # The version of External Secrets to use.
    gateway-api_version      = string # The version of Gateway API to use.
    gateway-api_channel      = string # The channel of Gateway API to use (standard OR experimental).
  })
}

variable "nameservers" {
  description = "The nameservers to use for the cluster."
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
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
      gateway          = optional(string, "")
      mtu              = optional(number, 1500)
      dhcp_routeMetric = optional(number, 100)
      routes = optional(list(object({
        gateway     = string
        destination = optional(string, "")
      })), [])
      vlans = optional(list(object({
        vlanId           = number
        addresses        = list(string)
        dhcp_routeMetric = optional(number, 100)
      })), [])
    }))
    primary_ip = optional(string, "")
  }))
}

variable "ts_authkey" {
  description = "Tailscale auth key for connecting nodes to Tailscale network"
  type        = string
  sensitive   = true
}
