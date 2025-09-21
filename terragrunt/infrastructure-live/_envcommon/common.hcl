locals {
}

inputs = {
  talos_config_path   = "~/.talos"
  kube_config_path    = "~/.kube"
  nameservers         = ["1.1.1.1", "1.0.0.1"]
  timeservers         = ["0.pool.ntp.org", "1.pool.ntp.org"]
  cluster_node_subnet = "192.168.1.0/24"
  timeout             = "10m"
}
