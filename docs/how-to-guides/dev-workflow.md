---
sidebar_position: 11
title: Development Workflow
---

# Development Workflow

Use the runner container to ensure consistent tooling when making changes.

## Start a shell

```shell
task docker:shell
```

## Validate changes

- Run `task cluster:status` to check cluster health.
- Use `task k8s:deploy` for manual manifest apply.
- Run `pre-commit run --all-files` before opening a PR.

## GitOps changes

1. Update files under `kubernetes/cluster/active/`.
2. Commit and push changes.
3. Validate in Argo CD.

## Related docs

- [GitOps Workflow](../explanation/gitops-workflow)
- [CI/CD Workflows](../reference/ci-cd-workflows)
- [Troubleshooting](troubleshooting)
