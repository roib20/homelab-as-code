variable "datastore_id" {
  description = "The ID of the datastore where the snippet will be stored"
  type        = string
  default     = "local"
}

variable "content_type" {
  description = "The content type of the datastore (usually snippets)"
  type        = string
  default     = "snippets"
}

variable "node_name" {
  description = "The name of the Proxmox node"
  type        = string
  default     = "pve"
}

variable "user_data_cloud_config" {
  description = "Path to the Cloud-init user-data YAML file"
  type        = string
  default     = "user-data-cloud-config.yaml"
}

variable "meta_data_cloud_config" {
  description = "Path to the Cloud-init meta-data YAML file"
  type        = string
  default     = "meta-data-cloud-config.yaml"
}

variable "vendor_data_cloud_config" {
  description = "Path to the Cloud-init vendor-data YAML file"
  type        = string
  default     = "vendor-data-cloud-config.yaml"
}

variable "hostname" {
  description = "The hostname to set in the cloud-config"
  type        = string
}

variable "vm_id" {
  description = "The ID of the virtual machine"
  type        = string
}

variable "region" {
  description = "The region label used in the provider ID and metadata"
  type        = string
}

variable "cpu" {
  description = "Number of virtual CPUs allocated to the VM"
  type        = number
}

variable "memory" {
  description = "Memory allocated to the VM in megabytes"
  type        = number
}

variable "zone" {
  description = "The zone the VM is placed in"
  type        = string
}
