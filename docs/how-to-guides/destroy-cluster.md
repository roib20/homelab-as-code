# Destroy the Cluster

This guide covers how to safely destroy the cluster and clean up resources.

## Preview destruction (dry run)

Before destroying anything, preview what would be deleted:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:down-dryrun"
```

This shows:

- Infrastructure that would be destroyed via Terragrunt
- Cloudflare resources (tunnels and DNS records) that would be deleted

## Destroy the cluster

To destroy the entire cluster:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:down"
```

This command prompts for confirmation and then:

1. Disables Argo CD sync to prevent resource recreation
2. Deletes all ingress resources
3. Cleans Cloudflare operator resources (tunnels and DNS)
4. Destroys the Talos cluster infrastructure via Terragrunt

## Rebuild the cluster

To destroy and immediately rebuild (useful for testing):

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:rebuild"
```

## Manual cleanup steps

If you need to run cleanup steps individually:

### Disable Argo CD sync

```shell
task argocd:disable-sync
```

### Delete ingress resources

Preview:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task k8s:delete-all-ingress-dryrun"
```

Delete:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task k8s:delete-all-ingress"
```

### Clean Cloudflare resources

Preview:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:clean-dryrun"
```

Delete:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cloudflare:clean"
```

### Destroy Talos infrastructure

Preview:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:plan-destroy"
```

Destroy:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:destroy"
```
