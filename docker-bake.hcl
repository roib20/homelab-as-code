# docker-bake.hcl

###############################################
# Variables
###############################################

variable "REGISTRY"    { default = "ghcr.io" }
variable "GIT_URL"     { default = "github.com" }
variable "OWNER"       { default = "roib20" }
variable "REPOSITORY"  { default = "homelab-as-code" }
variable "IMAGE_TITLE" { default = "homelab-as-code-runner" }
variable "TAGS"        { default = ["latest"] }

variable "DEFAULT_PLATFORMS" { default = ["linux/amd64,linux/arm64"] }

variable "OCI_LABELS" {
  type = map(string)
  default = {
    # "org.opencontainers.image.authors"       = "${OWNER}"
    "org.opencontainers.image.description"   = "CLI toolchain with OpenTofu, Terragrunt, Talosctl, Kubectl, Helm, Kustomize, Ansible, jq, go-task"
    # "org.opencontainers.image.documentation" = "https://${GIT_URL}/${OWNER}/${REPOSITORY}/blob/main/README.md"
    # "org.opencontainers.image.source"        = "https://${GIT_URL}/${OWNER}/${REPOSITORY}.git"
    # "org.opencontainers.image.title"         = "${IMAGE_TITLE}"
    # "org.opencontainers.image.url"           = "https://${REGISTRY}/${OWNER}/${IMAGE_TITLE}"
  }
}

######################
# Build targets      #
######################

target "docker-metadata-action" {}

target "base" {
  inherits = ["docker-metadata-action"]

  context    = "."
  dockerfile = "Dockerfile"

  output     = [{ type = "cacheonly" }]

  # Final stage to export
  target     = "runtime"

  # Pass all version/build args through (populated by `docker-bake.override.hcl`)
  args = {
    ALPINE_VERSION     = "${alpine}"
    TOFU_VERSION       = "${tofu}"
    TERRAGRUNT_VERSION = "${terragrunt}"
    TASK_VERSION       = "${go-task}"
    TALOS_VERSION      = "${talos}"
    YQ_VERSION         = "${yq}"
    KUBECTL_VERSION    = "${kubectl}"
    HELM_VERSION       = "${helm}"
    KUSTOMIZE_VERSION  = "${kustomize}"
    JQ_VERSION         = "${jq}"
    PYTHON_VERSION     = "${python}"
  }

  tags = [
    "${REGISTRY}/${OWNER}/${REPOSITORY}/${IMAGE_TITLE}:latest",
  ]

  # Same map drives both places – no duplication
  labels      = OCI_LABELS

  # Turn the map into the list of strings bake expects
  annotations = [
    for k, v in OCI_LABELS : "manifest:${k}=${v}"
  ]
}

target "multiarch-push" {
  inherits  = ["base"]

  output    = [{ type = "registry" }]
  platforms = "${DEFAULT_PLATFORMS}"

  attest = [
    "type=provenance,mode=max",
    "type=sbom",
  ]

  # Add index annotations for multi platform export
  annotations = [
    for k, v in OCI_LABELS : "index,manifest:${k}=${v}"
  ]
}

# Single‑arch build into local daemon
target "local" {
  inherits  = ["base"]

  output    = [{ type = "docker" }]
  platforms = ["${BAKE_LOCAL_PLATFORM}"]

  tags = [
    "${IMAGE_TITLE}:latest",
  ]
}

# # "test" stage

# target "test" {
#   context    = "."
#   dockerfile = "Dockerfile"
#   target     = "test"
#   output     = [{ type = "cacheonly" }]
# }

######################
# Convenience groups #
######################

group "default"  { targets = ["local"] }
group "local"    { targets = ["local"] }
group "push"     { targets = ["multiarch-push"] }
group "validate" { targets = ["test"] }
