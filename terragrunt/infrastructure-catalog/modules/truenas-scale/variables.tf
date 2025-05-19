########################################################
# Variables driven by Terragrunt inputs
########################################################

variable "iso_url" {
  description = "URL to the TrueNAS SCALE installation ISO."
  type        = string
}

variable "iso_checksum" {
  description = "Checksum of the ISO file."
  type        = string
}

variable "iso_checksum_algorithm" {
  description = "Checksum algorithm for the ISO file."
  type        = string
  default     = "sha256"
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
  default     = 3000
}

variable "vm_datastore_id" {
  description = "Proxmox datastore where VM disks will be stored."
  type        = string
  default     = "local-lvm"
}

variable "memory_dedicated" {
  description = "Dedicated memory for the VM in MiB."
  type        = number
  default     = 1024
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

variable "pci_device" {
  description = "PCI device passthrough identifier."
  type        = string
  default     = "hostpci0"
}

variable "pci_mapping" {
  description = "Proxmox hostpci mapping label."
  type        = string
  default     = "LSI"
}
