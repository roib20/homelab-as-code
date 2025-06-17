locals {
  # Ensure unique file paths
  manifest_files = toset(var.manifest_yaml_files)
}

resource "kubernetes_manifest" "apply" {
  for_each = local.manifest_files

  # Render the manifest template if variables provided, otherwise load raw
  manifest = yamldecode(
    length(keys(var.template_vars)) > 0
      ? templatefile(each.value, var.template_vars)
      : file(each.value)
  )
}
