# Set common variables for multiple nodes. This is automatically pulled in in the root root.hcl configuration to
# configure the remote state bucket and is accessible as inputs in child units.
locals {
  nodes = {
    "pve-01" = {
      address = "https://pve-01:8006/"
    }
    "pve-02" = {
      address = "https://pve-02:8006/"
    }
    "pve-03" = {
      address = "https://pve-03:8006/"
    }
  }
  # For backward compatibility
  node_name    = keys(local.nodes)[0]
  node_address = local.nodes[local.node_name].address
}
