########################################################
# Variables driven by Terragrunt inputs
########################################################

variable "talos_version" {
  description = "Talos version (e.g. v1.10.1)"
  type        = string
}

variable "talos_image_schematic_id" {
  description = "Talos image schematic ID (from Talos Linux Image Factory: https://factory.talos.dev/)"
  type        = string
}

variable "iso_datastore_id" {
  description = "Proxmox datastore where the ISO will be downloaded."
  type        = string
  default     = "local"
}

variable "node_name" {
  description = "Proxmox node on which to create resources."
  type        = string
  default     = "pve"
}

variable "vm_name" {
  description = "Name of the VM."
  type        = string
  default     = ""
}

variable "vm_id" {
  description = "ID of the VM."
  type        = number
  default     = 4000
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM."
  type        = number
  default     = 2
}

variable "memory_dedicated" {
  description = "Dedicated memory for the VM in MiB."
  type        = number
  default     = 4096
}

variable "agent" {
  description = "Enable the QEMU guest agent."
  type        = bool
  default     = true
}

variable "vm_datastore_id" {
  description = "Proxmox datastore where VM disks will be stored."
  type        = string
  default     = "local-lvm"
}

variable "disk_size_gb" {
  description = "Size of the VM disks in GiB."
  type        = number
  default     = 4
}

variable "bridge" {
  description = "Bridge device to attach the network interface."
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "IPv4 address to assign to the VM."
  type        = string
  default     = "192.168.1.100"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway for the VM."
  type        = string
  default     = "192.168.1.1"
}

variable "cluster_name" {
  description = "Talos Cluster"
  type        = string
  default     = "talos"
}

variable "talos_machine_type" {
  description = "Talos Machine Type, either 'controlplane' or 'worker'"
  type        = string
  default     = "controlplane"
}
