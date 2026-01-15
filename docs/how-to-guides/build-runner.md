---
sidebar_position: 3
title: Build the Runner Container
---

# Build the Runner Container

The runner image contains all tools needed for provisioning (Ansible, Terragrunt, OpenTofu, kubectl, talosctl, and task). Build it locally before running tasks.

## Build locally

```shell
task docker:build
```

This runs `docker buildx bake local` and produces the `homelab-as-code-runner:latest` image.

## Start an interactive shell

```shell
task docker:shell
```

## Run a one-off command

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:info"
```

## Next steps

- [Configure environment variables](configure-env)
- [Getting Started](../tutorials/getting-started)
