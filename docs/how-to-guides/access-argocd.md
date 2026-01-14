# Access Argo CD

This guide covers how to access the Argo CD web interface and retrieve credentials.

## Prerequisites

- A running cluster (created via `task cluster:up`)
- kubectl configured with cluster access

## Get the admin password and start port-forward

Run:

```shell
task argocd
```

This retrieves the initial admin password and starts a port-forward to `http://localhost:8080`.

## Individual steps

If you need to run the steps separately:

### Get the admin password

```shell
task argocd:password
```

### Start port-forward

```shell
task argocd:port-forward
```

Access Argo CD at `http://localhost:8080` with username `admin`.

## Reset the admin password

If you need to reset the admin password:

```shell
task argocd:reset-password
```

This runs a 3-step process:

1. Invalidates the current admin credentials
2. Restarts the Argo CD server pods
3. Retrieves the new password from the regenerated secret

## Delete the initial admin secret

After setting a custom password through the Argo CD UI, delete the initial secret:

```shell
task argocd:delete-initial-secret
```

## Disable or enable sync

To temporarily disable Argo CD from syncing resources (useful during maintenance):

```shell
task argocd:disable-sync
```

To re-enable:

```shell
task argocd:enable-sync
```

This scales the application controller StatefulSet to 0 or 1 replicas.
