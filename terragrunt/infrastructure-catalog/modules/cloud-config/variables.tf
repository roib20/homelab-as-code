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
  type        = string
}

variable "vm_id" {
  type        = string
}

variable "instance_type" { 
  type        = string
}

variable "cluster_name" {
  type        = string
  default     = "talos"
}

variable "zone" {
  type        = string
  default     = "talos"
}
