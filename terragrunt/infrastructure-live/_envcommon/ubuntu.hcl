# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
    # Proxmox target
  node_name = "pve"

  # ISO download
  iso_url                = "https://cloud-images.ubuntu.com/releases/noble/release-20250516/ubuntu-24.04-server-cloudimg-amd64.img"
  iso_checksum           = "8d6161defd323d24d66f85dda40e64e2b9021aefa4ca879dcbc4ec775ad1bbc5"
  iso_checksum_algorithm = "sha256"
  iso_datastore_id       = "local"

  # VM identity
  vm_name = ""          # leave empty or set e.g. "truenas"
  vm_id   = 4000        # override as needed

  # Storage & resources
  vm_datastore_id  = "VM"
  memory_dedicated = 4096
  disk_size_gb     = 32

  # IPv4
  ipv4_address = "192.168.1.20"
}
