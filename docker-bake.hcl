# docker-bake.hcl

###############################################
# Variables
###############################################

variable "REGISTRY" { default = "ghcr.io" }
variable "GIT_URL" { default = "github.com" }
variable "OWNER" { default = "roib20" }
variable "REPOSITORY" { default = "homelab-as-code" }
variable "IMAGE_TITLE" { default = "homelab-as-code-runner" }
variable "TAGS" { default = ["latest"] }

variable "DEFAULT_PLATFORMS" { default = ["linux/amd64,linux/arm64"] }

variable "OCI_LABELS" {
  type = map(string)
  default = {
    # "org.opencontainers.image.authors"       = "${OWNER}"
    "org.opencontainers.image.description" = "CLI toolchain with OpenTofu, Terragrunt, Talosctl, Kubectl, Helm, Kustomize, Ansible, jq, go-task"
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

  output = [{ type = "cacheonly" }]

  # Base runtime stage (CLI runner)
  target = "runtime"

  # Pass all version/build args through (populated by `docker-bake.override.hcl`)
  args = {
    ALPINE_VERSION     = "${alpine}"
    TOFU_VERSION       = "${tofu}"
    TERRAGRUNT_VERSION = "${terragrunt}"
    TASK_VERSION       = "${go-task}"
    TALOS_VERSION      = "${talos}"
    KUBECTL_VERSION    = "${kubectl}"
    HELM_VERSION       = "${helm}"
    KUSTOMIZE_VERSION  = "${kustomize}"
    JQ_VERSION         = "${jq}"
    PYTHON_VERSION     = "${python}"
    GO_VERSION         = "${go}"
    TTYREC_VERSION     = "${ttyrec}"
  }

  tags = [
    "${REGISTRY}/${OWNER}/${REPOSITORY}/${IMAGE_TITLE}:latest",
  ]

  # Same map drives both places – no duplication
  labels = OCI_LABELS

  # Turn the map into the list of strings bake expects
  annotations = [
    for k, v in OCI_LABELS : "manifest:${k}=${v}"
  ]
}

target "multiarch-push" {
  inherits = ["base"]

  # Override to use task-ui-runtime as final stage for production
  target = "task-ui-runtime"

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

# Single‑arch build into local daemon (task-ui)
target "local" {
  inherits = ["base"]

  # Override to use task-ui-runtime as final stage for local builds too
  target = "task-ui-runtime"

  output    = [{ type = "docker" }]
  platforms = ["${BAKE_LOCAL_PLATFORM}"]

  tags = [
    "${IMAGE_TITLE}:latest",
  ]
}

# CLI-only runtime stage for local builds
target "runtime-local" {
  inherits = ["base"]

  output    = [{ type = "docker" }]
  platforms = ["${BAKE_LOCAL_PLATFORM}"]

  tags = [
    "${IMAGE_TITLE}:runtime",
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

# Individual toolchain targets (local builds only)
target "terragrunt-local" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "terragrunt"

  output    = [{ type = "docker" }]
  platforms = ["${BAKE_LOCAL_PLATFORM}"]

  args = {
    ALPINE_VERSION     = "${alpine}"
    TOFU_VERSION       = "${tofu}"
    TERRAGRUNT_VERSION = "${terragrunt}"
  }

  tags = ["${IMAGE_TITLE}:terragrunt"]
}

target "kubectl-local" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "kubectl"

  output    = [{ type = "docker" }]
  platforms = ["${BAKE_LOCAL_PLATFORM}"]

  args = {
    ALPINE_VERSION    = "${alpine}"
    KUBECTL_VERSION   = "${kubectl}"
    HELM_VERSION      = "${helm}"
    KUSTOMIZE_VERSION = "${kustomize}"
  }

  tags = ["${IMAGE_TITLE}:kubectl"]
}

group "default" { targets = ["local"] }
group "local" { targets = ["local"] }
group "push" { targets = ["multiarch-push"] }
group "validate" { targets = ["test"] }
