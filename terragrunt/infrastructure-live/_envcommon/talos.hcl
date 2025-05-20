# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
    # Proxmox target
  node_name = "pve"

  # ISO download
  talos_version                      = "v1.10.2"
  talos_image_schematic_id           = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"

  # VM identity
  vm_name = "talos"          # leave empty or set e.g. "truenas"
  vm_id   = 4000        # override as needed

  # Storage & resources
  vm_datastore_id  = "VM"
  memory_dedicated = 4096
  disk_size_gb     = 32

  # IPv4
  ipv4_address = "192.168.1.20"
}
