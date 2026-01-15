---
sidebar_position: 9
title: Runner Container
---

# Runner Container

The runner image bundles the tooling required for provisioning and operations.

## Key tools

- `ansible` and `ansible-playbook`
- `terragrunt` and `tofu`
- `kubectl` and `talosctl`
- `task` runner

## Build and run

```shell
task docker:build
```

```shell
task docker:run
```

## Related docs

- [Build the Runner Container](../how-to-guides/build-runner)
- [Taskfile Commands](taskfile-commands)
