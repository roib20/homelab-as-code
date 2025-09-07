locals {
  nodes = {
    "pve-node-02" = {
      address = "https://pve-node-02:8006/"
    }
  }
  # For backward compatibility
  node_name    = keys(local.nodes)[0]
  node_address = local.nodes[local.node_name].address
}
