# Set common variables for multiple nodes. This is automatically pulled in in the `root.hcl` configuration to
# configure the remote state bucket and is accessible as inputs in child units.
locals {
  nodes = {
    "pve-node-01" = {
      address = "https://pve-node-01:8006/"
    }
    "pve-node-02" = {
      address = "https://pve-node-02:8006/"
    }
    "pve-node-03" = {
      address = "https://pve-node-03:8006/"
    }
  }
  # For backward compatibility
  node_name    = keys(local.nodes)[0]
  node_address = local.nodes[local.node_name].address
}
