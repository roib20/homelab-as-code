locals {
  # Ensure unique file paths
  manifest_files = toset(var.manifest_yaml_files)
}

resource "kubernetes_manifest" "apply" {
  for_each = local.manifest_files
  manifest = yamldecode(file(each.value))
}
