---
sidebar_position: 15
title: Scale the Cluster
---

# Scale the Cluster

Scaling the cluster is done by updating the Terragrunt Talos stack configuration.

## Update the Talos stack

1. Edit the `talos-cluster` configuration in `terragrunt/infrastructure-live/<env>/<node>/talos-cluster` to add or remove machines.
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

## Related docs

- [Update Talos Linux](update-talos)
- [Troubleshooting](troubleshooting)
