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

######################
# Build targets      #
######################

target "base" {
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

  labels = {
    "org.opencontainers.image.title"       = "${IMAGE_TITLE}"
    "org.opencontainers.image.authors"     = "${OWNER}"
    "org.opencontainers.image.description" = "CLI toolchain with OpenTofu, Terragrunt, Talosctl, Kubectl, Helm, Kustomize, Ansible, jq, go-task"
    "org.opencontainers.image.url"         = "https://${REGISTRY}/${OWNER}/${IMAGE_TITLE}"
    "org.opencontainers.image.source"      = "https://${GIT_URL}/${OWNER}/${REPOSITORY}/${IMAGE_TITLE}"
    "org.opencontainers.image.version"     = "latest"
  }

  annotations = [
    "org.opencontainers.image.title=${IMAGE_TITLE}",
    "org.opencontainers.image.authors=${OWNER}",
    "org.opencontainers.image.description=CLI toolchain with OpenTofu, Terragrunt, Talosctl, Kubectl, Helm, Kustomize, Ansible, jq, go-task",
    "org.opencontainers.image.url=https://${REGISTRY}/${OWNER}/${IMAGE_TITLE}",
    "org.opencontainers.image.source=https://${GIT_URL}/${OWNER}/${REPOSITORY}/${IMAGE_TITLE}",
    "org.opencontainers.image.version=latest",
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
