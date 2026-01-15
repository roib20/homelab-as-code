---
sidebar_position: 9
title: Update Talos Linux
---

# Update Talos Linux

Talos upgrades are managed through the Terragrunt stack and applied with Taskfile commands.

## Update the version

1. Edit the Talos stack configuration under `terragrunt/infrastructure-live/<env>/<node>/talos-cluster` to the desired version.
2. Preview changes:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:plan"
```

3. Apply the update:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:apply"
```

## Verify

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:status"
```

## Related guides

- [Update the Cluster](update-cluster)
- [Troubleshooting](troubleshooting)
