---
sidebar_position: 3
title: CI/CD Workflows
---

# CI/CD Workflows

GitHub Actions workflows validate infrastructure and build the runner image.

## Workflows

- **Bake Container Image**: builds and signs the runner image on changes to Docker build files.
- **pre-commit**: runs the shared pre-commit hooks on pull requests and main.
- **Kustomize Build Validation**: builds Kustomize overlays and runs kubeconform linting.
- **Terragrunt Validate & Format**: validates all Terragrunt stacks and formatting.
- **ShellCheck**: lints shell scripts.
- **yamllint**: lints YAML files and runs ansible-lint across playbooks.

## Related docs

- [Pre-commit Hooks](pre-commit-hooks)
- [Directory Structure](directory-structure)
