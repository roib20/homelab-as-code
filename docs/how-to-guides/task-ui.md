---
sidebar_position: 6
title: Use Task UI
---

# Use Task UI

Task UI provides a browser-based way to run Taskfile commands.

## Start the service

```shell
task task-ui:up
```

Task UI listens on `http://localhost:3000`.

## Expose via Tailscale (optional)

```shell
task task-ui:serve
```

## Stop the service

```shell
task task-ui:stop
```

## Teardown

```shell
task task-ui:teardown
```

## Related guides

- [Build the Runner Container](build-runner)
- [Troubleshooting](troubleshooting)
