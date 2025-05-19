# Set common variables for the node. This is automatically pulled in in the root root.hcl configuration to
# configure the remote state bucket and is accessible as inputs in child units.
locals {
  node_name    = "pve"
  node_address = "https://pve:8006/"
}
