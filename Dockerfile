# syntax=docker/dockerfile:1.7
# Multi‑arch capable Dockerfile – relies on BuildKit‑provided TARGETOS/TARGETARCH

#############################################
# Global build arguments (injected by Bake)  #
#############################################
ARG ALPINE_VERSION=3.22
ARG TOFU_VERSION=1.9.1
ARG TERRAGRUNT_VERSION=0.82.3
ARG TASK_VERSION=3.44.0
ARG TALOS_VERSION=1.10.5
ARG YQ_VERSION=4.45.4
ARG KUBECTL_VERSION=1.33.0
ARG HELM_VERSION=3.14.2
ARG KUSTOMIZE_VERSION=5.7.0
ARG JQ_VERSION=1.8.1
ARG OS=linux
ARG ARCH=amd64
ARG PYTHON_VERSION=3.13
# BuildKit automatically provides:
#   TARGETOS   – linux
#   TARGETARCH – amd64 | arm64
ARG TARGETOS=linux
ARG TARGETARCH=amd64

############################################################
# Stage 1: tofu binary (same for every arch – no Go runtime)
############################################################
FROM ghcr.io/opentofu/opentofu:${TOFU_VERSION}-minimal AS tofu

###########################################
# Stage 0 – generic downloader utilities  #
###########################################
FROM alpine:${ALPINE_VERSION} AS downloader
ARG CURL_FLAGS="-sSL --proto '=https' --tlsv1.3 --ciphers 'HIGH:!aNULL:!MD5' --cacert /etc/ssl/certs/ca-certificates.crt --capath /etc/ssl/certs --compressed"
RUN apk add --no-cache curl

# --- dl-verify helper ---
RUN cat <<'EOF' >/usr/local/bin/dl-verify && chmod +x /usr/local/bin/dl-verify
#!/bin/sh
# dl-verify URL FILE CHECKSUM_URL [DEST=/usr/local/bin] [CHECKSUM_HASH]
set -eu
url="$1"; file="$2"; checksum_url="$3"; install_name="${4:-$(basename "$file")}"; sum_cmd="${5:-sha256}"
dest="/usr/local/bin"
tmp_dir="$(mktemp -d)"; trap 'rm -rf "$tmp_dir"' EXIT INT TERM
curl ${CURL_FLAGS:-"-sSL"} -o "$tmp_dir/$file" "$url"
curl ${CURL_FLAGS:-"-sSL"} -o "$tmp_dir/${sum_cmd}sum.txt" "$checksum_url"
calc="$("$sum_cmd"sum "$tmp_dir/$file" | awk '{print $1}')"
exp="$(grep " $file" "$tmp_dir/${sum_cmd}sum.txt" | awk '{print $1}' || true)"
[ -z "$exp" ] && exp="$(tr -d '[:space:]' < "$tmp_dir/${sum_cmd}sum.txt")"
[ "$calc" = "$exp" ] || { echo "Checksum mismatch for $file" >&2; exit 1; }
case "$file" in *.tar.gz|*.tgz) tar -xzf "$tmp_dir/$file" -C "$dest";; *) install -m 0755 "$tmp_dir/$file" "$dest/$install_name";; esac
chmod +x "$dest"/*
EOF

#################################################
# Stage 2 – Download architecture‑specific CLIs #
#################################################

# Terragrunt
FROM downloader AS terragrunt
ARG TERRAGRUNT_VERSION TARGETOS TARGETARCH
ENV FILE="terragrunt_${TARGETOS}_${TARGETARCH}" \
    CHECKSUM_FILE="SHA256SUMS" \
    VERSION="${TERRAGRUNT_VERSION}" \
    URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${VERSION}"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" terragrunt

# go-task
FROM downloader AS go-task
ARG TASK_VERSION TARGETOS TARGETARCH
ENV FILE="task_${TARGETOS}_${TARGETARCH}.tar.gz" \
    CHECKSUM_FILE="task_checksums.txt" \
    VERSION="${TASK_VERSION}" \
    URL="https://github.com/go-task/task/releases/download/v${VERSION}"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" task

# jq
FROM downloader AS jq
ARG JQ_VERSION TARGETOS TARGETARCH
ENV FILE="jq-${TARGETOS}-${TARGETARCH}" \
    CHECKSUM_HASH="sha256" \
    CHECKSUM_FILE="${CHECKSUM_HASH}sum.txt" \
    VERSION="${JQ_VERSION}" \
    URL="https://github.com/jqlang/jq/releases/download"
RUN dl-verify "${URL}/jq-${VERSION}/${FILE}" "${FILE}" "${URL}/jq-${VERSION}/${CHECKSUM_FILE}" jq

# talosctl
FROM downloader AS talosctl
ARG TALOS_VERSION TARGETOS TARGETARCH
ENV FILE="talosctl-${TARGETOS}-${TARGETARCH}" \
    CHECKSUM_HASH="sha512" \
    CHECKSUM_FILE="${CHECKSUM_HASH}sum.txt" \
    VERSION="${TALOS_VERSION}" \
    URL="https://github.com/siderolabs/talos/releases/download/v${VERSION}"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" talosctl "${CHECKSUM_HASH}"

# kubectl
FROM downloader AS kubectl
ARG KUBECTL_VERSION TARGETOS TARGETARCH
ENV FILE="kubectl" \
    CHECKSUM_FILE="${FILE}.sha256" \
    VERSION="${KUBECTL_VERSION}" \
    URL="https://dl.k8s.io/release/v${VERSION}/bin/${TARGETOS}/${TARGETARCH}"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" kubectl

# helm
FROM downloader AS helm
ARG HELM_VERSION TARGETOS TARGETARCH
ENV FILE="helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" \
    CHECKSUM_FILE="${FILE}.sha256" \
    URL="https://get.helm.sh"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" helm && \
    mv "/usr/local/bin/${TARGETOS}-${TARGETARCH}/helm" /usr/local/bin/helm && \
    rm -r "/usr/local/bin/${TARGETOS}-${TARGETARCH}"

# kustomize
FROM downloader AS kustomize
ARG KUSTOMIZE_VERSION TARGETOS TARGETARCH
ENV FILE="kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" \
    CHECKSUM_FILE="checksums.txt" \
    URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}"
RUN dl-verify "${URL}/${FILE}" "${FILE}" "${URL}/${CHECKSUM_FILE}" kustomize

############################################
# Stage 3 – Ansible virtual environment    #
############################################
FROM python:${PYTHON_VERSION}-alpine AS ansible
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m venv $VIRTUAL_ENV && \
    pip install --upgrade pip && \
    pip install --no-cache-dir ansible-core argcomplete kubernetes

FROM ansible AS ansible-requirements
COPY --link ansible/requirements.yml /.
RUN ansible-galaxy install -r requirements.yml --force

############################################
# Stage 4 – Final runtime image           #
############################################
FROM python:${PYTHON_VERSION}-alpine AS runtime
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# COPY binaries & venv
COPY --link --from=tofu /usr/local/bin/tofu /usr/local/bin/
COPY --link --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/
COPY --link --from=go-task /usr/local/bin/task /usr/local/bin/
COPY --link --from=jq /usr/local/bin/jq /usr/local/bin/
COPY --link --from=talosctl /usr/local/bin/talosctl /usr/local/bin/
COPY --link --from=kubectl /usr/local/bin/kubectl /usr/local/bin/
COPY --link --from=helm /usr/local/bin/helm /usr/local/bin/
COPY --link --from=kustomize /usr/local/bin/kustomize /usr/local/bin/
COPY --link --from=ansible $VIRTUAL_ENV $VIRTUAL_ENV
COPY --link --from=ansible-requirements /root/.ansible /home/runner/.ansible

# Runtime dependencies only
RUN apk add --no-cache \
      openssh-client \
      sshpass \
      less \
      ca-certificates

# Rootless user
WORKDIR /homelab-as-code
ENV USER="runner" LOGNAME="runner" HOME="/home/runner"
RUN addgroup -S runner && adduser -S runner -G runner && \
    find "/home/runner/.ansible/" -mindepth 1 -maxdepth 1 ! -name "collections" ! -name "roles" -exec rm -rf {} + && \
    chown -R runner:runner "$HOME" && chmod -R o+rwx "$HOME"
USER runner

CMD ["/bin/sh"]
