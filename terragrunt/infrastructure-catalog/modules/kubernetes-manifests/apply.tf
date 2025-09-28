locals {
  # Ensure unique file paths
  secret_files   = toset(var.secret_yaml_files)
  manifest_files = setsubtract(toset(var.manifest_yaml_files), local.secret_files)
}

resource "kubernetes_manifest" "apply" {
  for_each = local.manifest_files

  # Render the manifest template if variables provided, otherwise load raw
  manifest = sensitive(
    yamldecode(
      length(keys(var.template_vars)) > 0
      ? templatefile(each.value, var.template_vars)
      : file(each.value)
    )
  )

  # lifecycle {
  #   # After the initial apply, the lifecycle of Kubernetes resources is managed by a GitOps tool (Argo CD or Flux)
  #   ignore_changes = all
  # }
}

resource "kubernetes_secret" "apply" {
  # Render secret templates inside the resource so state stores only the final object
  for_each = {
    for path in local.secret_files :
    path => yamldecode(
      length(keys(var.template_vars)) > 0
      ? templatefile(path, var.template_vars)
      : file(path)
    )
  }

  # Copy the rendered manifest metadata into the Kubernetes Secret resource
  metadata {
    name        = each.value.metadata.name
    namespace   = try(each.value.metadata.namespace, null)
    labels      = try(each.value.metadata.labels, null)
    annotations = try(each.value.metadata.annotations, null)
  }

  # Preserve any explicit Secret type, defaulting to Opaque when omitted
  type = try(each.value.type, "Opaque")

  # Merge plaintext stringData into data so sensitive payloads stay base64-encoded
  data = sensitive(
    merge(
      try(each.value.data, {}),
      { for key, value in try(each.value.stringData, {}) : key => base64encode(value) }
    )
  )
}
