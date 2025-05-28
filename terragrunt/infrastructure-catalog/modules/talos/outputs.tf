output "talosconfig" {
  description = "Talos configuration file"
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  description = "kubeconfig file"
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
