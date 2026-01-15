---
sidebar_position: 4
title: Pre-commit Hooks
---

# Pre-commit Hooks

Pre-commit ensures consistent formatting and security checks before commits.

## Included hooks

- `gitleaks` for secrets detection
- `check-*` hooks for file integrity and formatting
- `shellcheck` for shell script linting
- `yamllint` for YAML linting
- `terragrunt-hcl-fmt` and `tofu-fmt` for IaC formatting

## Usage

```shell
pre-commit run --all-files
```

## Related docs

- [CI/CD Workflows](ci-cd-workflows)
