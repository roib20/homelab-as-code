# Update the Cluster

This guide covers different methods for updating cluster components.

## GitOps updates (recommended)

For applications managed by Argo CD, updates happen automatically when you push changes to the repository.

1. Modify the relevant files in `kubernetes/cluster/active/`
2. Commit and push to the repository
3. Argo CD syncs the changes automatically

## Update Kubernetes manifests

To manually trigger a deployment of Kubernetes manifests:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task k8s:deploy"
```

This runs the Ansible playbook that applies Kustomize overlays.

## Update bootstrap secrets

If you need to re-apply the Bitwarden secrets:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task k8s:bootstrap-secrets"
```

## Preview infrastructure changes

Before applying Talos cluster changes, preview them:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:plan"
```

## Apply infrastructure changes

To apply changes to the Talos cluster infrastructure:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task talos:apply"
```

## Check cluster status

View current cluster health:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:status"
```

This shows:

- Cluster nodes and their status
- All pods across namespaces
- Argo CD applications

## Check cluster info

Get cluster information and Argo CD access details:

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:info"
```
