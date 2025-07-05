# syntax=docker/dockerfile:1

# Multi-platform builds
ARG TARGETOS
ARG TARGETARCH

# Versions
ARG ALPINE_VERSION=3.22
ARG TOFU_VERSION=1.9.1
ARG TERRAGRUNT_VERSION
ARG TASK_VERSION
ARG TALOS_VERSION
ARG YQ_VERSION
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG KUSTOMIZE_VERSION
ARG JQ_VERSION
ARG PYTHON_VERSION=3.22

# Stage 1: Extract tofu binary
FROM ghcr.io/opentofu/opentofu:${TOFU_VERSION}-minimal AS tofu

# Stage 0 – common downloader utilities
FROM alpine:${ALPINE_VERSION} AS downloader
ENV CURL_FLAGS="-sSL --proto '=https' --tlsv1.3 --ciphers 'HIGH:!aNULL:!MD5' --cacert /etc/ssl/certs/ca-certificates.crt --capath /etc/ssl/certs --compressed"
RUN apk add --no-cache curl

# ----- generic download / verify / (optionally) extract helper -----
RUN cat <<'EOF' >/usr/local/bin/dl-verify && \
chmod +x /usr/local/bin/dl-verify
#!/bin/sh
# dl-verify URL FILE CHECKSUM_URL [DEST=/usr/local/bin]
set -eu

url="${1}"                 # full URL to download
file="${2}"                # filename to download and compare to checksum
checksum_url="${3}"        # URL of SHA256 checksum file
install_name="${4:-$(basename "$file")}"         # optional rename
checksum_hash=$(printf '%s' "${5:-sha256}"| tr '[:upper:]' '[:lower:]')
dest="/usr/local/bin"         # fixed destination

tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT INT TERM

curl ${CURL_FLAGS:-"-sSL"} -o "$tmp_dir/$file" "$url"
curl ${CURL_FLAGS:-"-sSL"} -o "$tmp_dir/${checksum_hash}sum.txt" "$checksum_url"

CHECKSUM="$(${checksum_hash}sum "$tmp_dir/$file" | awk '{print $1}')"
EXPECTED_CHECKSUM="$(grep " $file" "$tmp_dir/${checksum_hash}sum.txt" | awk '{print $1}')"
if [ -z "${EXPECTED_CHECKSUM}" ]; then
  EXPECTED_CHECKSUM="$(tr -d '[:space:]' < "$tmp_dir/${checksum_hash}sum.txt")"
fi
[ "$CHECKSUM" = "$EXPECTED_CHECKSUM" ] || { echo "Checksum mismatch for $file" >&2; exit 1; }

case "$file" in
  *.tar.gz|*.tgz)
      tar -xzf "$tmp_dir/$file" -C "$dest"
      ;;
  *)
      install -m 0755 "$tmp_dir/$file" "$dest/$install_name"
      ;;
esac
chmod +x "$dest/"*
EOF

FROM downloader AS terragrunt
ARG TERRAGRUNT_VERSION TARGETOS TARGETARCH
ENV FILE="terragrunt_${TARGETOS}_${TARGETARCH}"
ENV CHECKSUM_FILE="SHA256SUMS"
ENV VERSION="${TERRAGRUNT_VERSION}"
ENV URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${VERSION}"

RUN dl-verify \
    "${URL}/${FILE}" \
    "${FILE}" \
    "${URL}/${CHECKSUM_FILE}" \
    terragrunt

FROM downloader AS go-task
ARG TASK_VERSION TARGETOS TARGETARCH
ENV FILE="task_${TARGETOS}_${TARGETARCH}.tar.gz"
ENV CHECKSUM_FILE="task_checksums.txt"
ENV VERSION="${TASK_VERSION}"
ENV URL="https://github.com/go-task/task/releases/download/v${VERSION}"

RUN dl-verify \
    "${URL}/${FILE}" \
    "${FILE}" \
    "${URL}/${CHECKSUM_FILE}" \
    task

FROM downloader AS talosctl
ARG TALOS_VERSION TARGETOS TARGETARCH
ENV FILE="talosctl-${TARGETOS}-${TARGETARCH}"
ENV CHECKSUM_HASH="sha512"
ENV CHECKSUM_FILE="${CHECKSUM_HASH}sum.txt"
ENV VERSION="${TALOS_VERSION}"
ENV URL="https://github.com/siderolabs/talos/releases/download/v${VERSION}"

RUN dl-verify \
    "${URL}/${FILE}" \
    "${FILE}" \
    "${URL}/${CHECKSUM_FILE}" \
    talosctl \
    "${CHECKSUM_HASH}"

FROM downloader AS kubectl
ARG KUBECTL_VERSION TARGETOS TARGETARCH
ENV FILE="kubectl"
ENV CHECKSUM_FILE="${FILE}.sha256"
ENV VERSION="${KUBECTL_VERSION}"
ENV URL="https://dl.k8s.io/release/v${VERSION}/bin/${TARGETOS}/${TARGETARCH}"

RUN dl-verify \
    "${URL}/${FILE}" \
    "${FILE}" \
    "${URL}/${CHECKSUM_FILE}" \
    kubectl

FROM downloader AS helm
ARG HELM_VERSION TARGETOS TARGETARCH
ENV FILE="helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz"
ENV CHECKSUM_FILE="${FILE}.sha256"
ENV URL="https://get.helm.sh"

RUN dl-verify \
      "${URL}/${FILE}" \
      "${FILE}" \
      "${URL}/${CHECKSUM_FILE}" \
      helm \
    && mv "/usr/local/bin/${TARGETOS}-${TARGETARCH}/helm" /usr/local/bin/helm && \
    rm -r "/usr/local/bin/${TARGETOS}-${TARGETARCH}"

FROM downloader AS kustomize
ARG KUSTOMIZE_VERSION TARGETOS TARGETARCH
ENV FILE="kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz"
ENV CHECKSUM_FILE="checksums.txt"
ENV URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}"

RUN dl-verify \
      "${URL}/${FILE}" \
      "${FILE}" \
      "${URL}/${CHECKSUM_FILE}" \
      kustomize
# Stage 4: Build Ansible in a venv
FROM python:${PYTHON_VERSION}-alpine AS ansible
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN \
    python3 -m venv $VIRTUAL_ENV \
    && pip install --upgrade pip \
    && pip install --no-cache-dir ansible-core argcomplete kubernetes

FROM ansible AS ansible-requirements
# Bring in requirements file
COPY --link ansible/requirements.yml /.
# RUN ansible-galaxy collection install community.general --force
RUN ansible-galaxy install -r requirements.yml --force

# Stage 5: Final runtime image
FROM python:${PYTHON_VERSION}-alpine AS runtime
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy venv and pre-built binaries
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=go-task /usr/local/bin/task /usr/local/bin/
COPY --from=talosctl /usr/local/bin/talosctl /usr/local/bin/
COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/
COPY --from=helm /usr/local/bin/helm /usr/local/bin/
COPY --from=kustomize /usr/local/bin/kustomize /usr/local/bin/
COPY --from=ansible $VIRTUAL_ENV $VIRTUAL_ENV
COPY --from=ansible-requirements /root/.ansible/collections /root/.ansible/collections
# COPY --from=ansible /root/.ansible/roles /root/.ansible/roles

# Install only runtime dependencies
RUN apk add --no-cache \
      openssh-client \
      sshpass \
      less \
      ca-certificates

WORKDIR /workspace
CMD ["/bin/sh"]
