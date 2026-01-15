---
sidebar_position: 7
title: Runner Container Approach
---

# Runner Container Approach

The runner container ensures all infrastructure tooling stays consistent across hosts.

## Why a container

- Avoids local toolchain drift
- Keeps versions aligned with CI
- Provides repeatable provisioning steps

## How it is used

- `compose.yaml` mounts the repo and configuration directories.
- Tasks are run through `docker compose run ... runner` or `task docker:*`.

## Related docs

- [Runner Container](../reference/runner-container)
- [Build the Runner Container](../how-to-guides/build-runner)
