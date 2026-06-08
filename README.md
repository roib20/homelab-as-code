<!-- markdownlint-disable-next-line MD033 MD041 -->
<div align="center">

# 🏠 Homelab as Code 👨‍💻

**Bare-metal to a self-healing Kubernetes cluster, every layer as code. This is my homelab.**

[![Documentation](https://img.shields.io/badge/Documentation-homelab.towerofkubes.com-5E81AC?style=for-the-badge&logo=astro&logoColor=white)](https://homelab.towerofkubes.com)

The goal is to keep manual steps out of it as much as I can. Ansible and OpenTofu provision the OS layer and VMs, the nodes run Talos Linux, and Argo CD reconciles the cluster against Git. Most changes are a commit, and rebuilding a node means running the same code again.

## ✅ Status

[![Image](https://img.shields.io/badge/image-ghcr.io%2Froib20%2Fhomelab--as--code--runner-blue)](https://github.com/roib20/homelab-as-code/pkgs/container/homelab-as-code-runner)
[![Bake Container Image](https://github.com/roib20/homelab-as-code/actions/workflows/bake-image.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/bake-image.yml)
[![Kustomize Build Validation](https://github.com/roib20/homelab-as-code/actions/workflows/kustomize-build-validation.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/kustomize-build-validation.yml)
[![pre-commit](https://github.com/roib20/homelab-as-code/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/pre-commit.yml)
[![ShellCheck](https://github.com/roib20/homelab-as-code/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/shellcheck.yml)
[![Terragrunt Validate & Format](https://github.com/roib20/homelab-as-code/actions/workflows/terragrunt-validate-and-fmt.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/terragrunt-validate-and-fmt.yml)
[![yamllint](https://github.com/roib20/homelab-as-code/actions/workflows/yamllint.yml/badge.svg)](https://github.com/roib20/homelab-as-code/actions/workflows/yamllint.yml)

---

## 🧱 Built with Layers

```mermaid
flowchart LR
  hw["💻 Hardware"] --> deb["🐧 Debian"] --> pve["📦 Proxmox VE"]
  pve --> tn["🗄️ TrueNAS"]
  pve --> k8s["☸️ Talos + Kubernetes"]
  k8s --> argo["🚀 Argo CD"]
```

The lab is built bottom to top, and each layer assumes the one under it. A Proxmox VE cluster runs the Talos VMs that form Kubernetes, plus a TrueNAS VM for storage. The lower layers rarely change once they work, while the apps on top change frequently, with updates automated by Renovate Operator.

## 🔁 Kept in Sync with Git

```mermaid
flowchart LR
  git["Git (this repo)"] --> argo["Argo CD"] --> cluster["Cluster state"]
  argo -. corrects drift .-> cluster
```

This is the GitOps part. Git holds the desired state and Argo CD does the writing: it is the only thing that applies changes to the cluster, and ApplicationSets generate the apps from `kubernetes/cluster/active`. A rollback is a `git revert`. The one thing kept out of Git is secrets, which the External Secrets Operator pulls from Bitwarden Secrets Manager at runtime.

## 🚪 Two Ways In

```mermaid
flowchart LR
  req["Request"] --> pick{"Public or private?"}
  pick -->|Public| gw["🌐 Gateway API + WAF"]
  pick -->|Private| ts["🔒 Tailscale Operator"]
  gw --> svc["Service"]
  ts --> svc
```

Every service picks one of two Ingress paths. Public services come in through the Gateway API, where Envoy Gateway terminates TLS and runs a Coraza WAF. Private ones reside on the Tailnet instead, reachable only from approved devices.

## 🧰 The Stack

| Category | Tools |
| --- | --- |
| 🏗️ Infrastructure as Code (IaC) | OpenTofu, Terragrunt, Ansible |
| 🖥️ Hosts and Virtualization | Proxmox VE, TrueNAS, Talos Linux |
| 🔁 GitOps | Argo CD with ApplicationSets |
| 🌐 Networking | Cilium, CoreDNS, external-dns |
| 🚪 Ingress | Envoy Gateway (public), Tailscale Operator (private) |
| 🔑 Certificates and Secrets | cert-manager, External Secrets Operator (Bitwarden Secrets Manager) |
| 🪪 Identity | Kanidm with Kaniop |
| 💾 Storage | Longhorn, CSI drivers for NFS and SMB |
| 🛢️ Databases | CloudNativePG, mariadb-operator |
| ⚙️ Runner Toolchain | Task, talosctl, kubectl, Helm, Kustomize |

## 📂 What's in the Repo

| Path | Contents |
| --- | --- |
| [`ansible/`](ansible) | Proxmox VE setup and Kubernetes bootstrap playbooks |
| [`debian/`](debian) | Unattended Debian install (preseed) |
| [`Dockerfile`](Dockerfile) | The all-in-one runner image |
| [`kubernetes/`](kubernetes) | GitOps source of truth |
| [`.taskfiles/`](.taskfiles) | Task runner workflows |
| [`terragrunt/`](terragrunt) | Talos VM provisioning, with remote state in Cloudflare R2 |
| [`tofu/`](tofu) | OpenTofu bootstrap for the R2 state bucket |

## 📖 Read More

Tutorials, guides, reference material, and explanations are in the [docs](https://homelab.towerofkubes.com). Deep dives can be found at my [blog](https://www.towerofkubes.com/).

<!-- markdownlint-disable-next-line MD033 -->
</div>
