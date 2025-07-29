locals {
  nodes = {
    "pve-01" = {
      address = "https://pve-01:8006/"
    }
  }
  # For backward compatibility
  node_name    = keys(local.nodes)[0]
  node_address = local.nodes[local.node_name].address
}
