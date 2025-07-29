locals {
  nodes = {
    "pve-03" = {
      address = "https://pve-03:8006/"
    }
  }
  # For backward compatibility
  node_name    = keys(local.nodes)[0]
  node_address = local.nodes[local.node_name].address
}
