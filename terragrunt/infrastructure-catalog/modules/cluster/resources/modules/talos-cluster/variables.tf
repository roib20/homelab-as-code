variable "versions" {
  type = object({
    kubernetes_version = string # The version of Kubernetes to use.
    talos_version      = string # The version of Talos to use.
  })
}

variable "talos_cluster_config" {
  description = "The config for the talos cluster.  This will be applied to each controlplane node. See: https://www.talos.dev/v1.10/reference/configuration/v1alpha1/config/#Config.cluster"
  type        = string
}

variable "machines" {
  description = "A list of machines to create the talos cluster from."
  type = list(object({
    talos_config = string # https://www.talos.dev/v1.10/reference/configuration/v1alpha1/config/#Config.machine
    hostname     = string
    primary_ip   = string
    endpoint     = optional(string, "")
    machine_interfaces = list(object({
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
    machine_nameservers = optional(list(string), [])
    extensions          = optional(list(string), [])
    extra_kernel_args   = optional(list(string), [])
    secureboot          = optional(bool, false)
    architecture        = optional(string, "amd64")
    platform            = optional(string, "nocloud")
    sbc                 = optional(string, "")
  }))

  validation {
    condition     = length(var.machines) > 0
    error_message = "At least one machine must be provided."
  }
}

variable "cluster_vip" {
  description = "The VIP to use for the Talos cluster. Applied to control plane nodes."
  type        = string
}

variable "bootstrap_charts" {
  description = "A list of helm charts to bootstrap into talos via inline_manifests."
  type = list(object({
    repository = string
    chart      = string
    name       = string
    version    = string
    namespace  = string
    values     = string
  }))
  default = []
}

variable "zswap" {
  description = "Zswap configuration for Talos nodes"
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

variable "swap_disk_min" {
  description = "Minimum swap disk size in GB across Talos VM swap backing disks"
  type        = number
  default     = 0

  validation {
    condition     = var.swap_disk_min >= 0 && (!var.zswap.enabled || var.swap_disk_min > 0)
    error_message = "swap_disk_min must be non-negative, and greater than 0 when zswap is enabled."
  }
}

variable "swap_disk_max" {
  description = "Maximum swap disk size in GB across Talos VM swap backing disks"
  type        = number
  default     = 0

  validation {
    condition     = var.swap_disk_max >= var.swap_disk_min && (!var.zswap.enabled || var.swap_disk_max > 0)
    error_message = "swap_disk_max must be >= swap_disk_min, and greater than 0 when zswap is enabled."
  }
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

variable "timeout" {
  description = "The timeout to use for the Talos cluster."
  type        = string
  default     = "10m"
}

variable "ts_authkey" {
  description = "Tailscale auth key for connecting nodes to Tailscale network"
  type        = string
  sensitive   = true
}
