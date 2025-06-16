output "resource_name" {
  description = "The name of the applied Kubernetes resource"
  value       = try(kubernetes_manifest.apply.manifest["metadata"]["name"], null)
}

output "resource_kind" {
  description = "The kind of the applied Kubernetes resource"
  value       = try(kubernetes_manifest.apply.manifest["kind"], null)
}
