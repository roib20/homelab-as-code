# Layer 4: Taskfile (Talos Cluster)

Bootstrap the Talos Kubernetes cluster and GitOps resources using Taskfile workflows.

## What this layer does

- Provisions Talos nodes via Terragrunt
- Bootstraps Kubernetes with Argo CD
- Applies GitOps-managed addons and apps

## Steps

1. Create `.env` if you have not already:

   ```shell
   cp env.example .env
   ```

2. Fill out secret values. See [Configure Environment Variables](../../how-to-guides/configure-env).
3. Bootstrap the cluster:

   ```shell
   docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:up"
   ```

4. Wait for Argo CD to deploy and sync the cluster resources.

## Verification

```shell
docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:status"
```

## Next steps

- [Access Argo CD](../../how-to-guides/access-argocd)
- [Add a New Application](../../how-to-guides/add-application)
- [Update the Cluster](../../how-to-guides/update-cluster)

## Troubleshooting

- If bootstrap fails, verify `.env` values and Bitwarden tokens.
- If Argo CD does not sync, check application status in the UI.
- If nodes are not ready, use `talosctl health` inside the runner.
