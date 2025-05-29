locals {
}

inputs = {
  talos_config_path   = "~/.talos"
  kube_config_path    = "~/.kube"
  nameservers         = ["192.168.1.1"]
  timeservers         = ["0.pool.ntp.org", "1.pool.ntp.org"]
  cluster_node_subnet = "192.168.1.0/24"
  timeout             = "10m"
}
