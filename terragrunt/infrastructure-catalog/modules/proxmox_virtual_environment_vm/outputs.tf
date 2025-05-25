output "ipv4_addresses" {
  description = "The IPv4 addresses per network interface published by the QEMU agent (empty list when `agent.enabled` is `false`)."
  value       = proxmox_virtual_environment_vm.vm.ipv4_addresses
}

output "ipv6_addresses" {
  description = "The IPv6 addresses per network interface published by the QEMU agent (empty list when `agent.enabled` is `false`)."
  value       = proxmox_virtual_environment_vm.vm.ipv6_addresses
}

output "mac_addresses" {
  description = "The MAC addresses published by the QEMU agent with fallback to the network device configuration, if the agent is disabled."
  value       = proxmox_virtual_environment_vm.vm.mac_addresses
}

output "network_interface_names" {
  description = "The network interface names published by the QEMU agent (empty list when `agent.enabled` is `false`)."
  value       = proxmox_virtual_environment_vm.vm.network_interface_names
}
