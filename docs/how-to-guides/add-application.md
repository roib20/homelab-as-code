# Add a New Application

This guide explains how to add a new application to the cluster using the GitOps workflow.

## How ApplicationSets work

Argo CD uses ApplicationSets that scan for `config.json` files in specific paths:

- **Addons**: `kubernetes/cluster/active/addons/**/overlays/*/config.json`
- **Apps**: `kubernetes/cluster/active/apps/**/overlays/*/config.json`
- **Resources**: `kubernetes/cluster/active/resources/**/overlays/*/config.json`
- **Ingress controllers**: `kubernetes/cluster/active/ingress-controllers/**/overlays/*/config.json`

When you add a new directory with a valid `config.json`, Argo CD automatically creates an Application for it.

## Directory structure

Each application follows this structure:

```text
kubernetes/cluster/active/apps/<category>/<app-name>/
├── base/
│   ├── kustomization.yaml
│   ├── namespace.yaml (optional)
│   └── values.yaml (for Helm charts)
└── overlays/
    └── prod/
        ├── config.json
        ├── kustomization.yaml
        └── values-override.yaml (optional)
```

## Step 1: Create the base directory

Create a new directory for your application:

```shell
mkdir -p kubernetes/cluster/active/apps/<category>/<app-name>/base
mkdir -p kubernetes/cluster/active/apps/<category>/<app-name>/overlays/prod
```

## Step 2: Create the base kustomization

Create `base/kustomization.yaml`. For a Helm chart:

```yaml title="base/kustomization.yaml"
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
  - name: <chart-name>
    repo: <helm-repo-url>
    version: <version>
    releaseName: <release-name>
    namespace: <namespace>
    valuesFile: values.yaml
```

For plain manifests, list your resource files instead:

```yaml title="base/kustomization.yaml"
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
```

## Step 3: Create Helm values (if applicable)

If using a Helm chart, create `base/values.yaml` with your configuration.

## Step 4: Create the prod overlay

Create `overlays/prod/kustomization.yaml`:

```yaml title="overlays/prod/kustomization.yaml"
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
```

To override Helm values, add a `values-override.yaml` and reference it:

```yaml title="overlays/prod/kustomization.yaml"
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
helmCharts:
  - name: <chart-name>
    valuesFile: values-override.yaml
```

## Step 5: Create config.json

Create `overlays/prod/config.json`:

```json title="overlays/prod/config.json"
{
  "annotations": {},
  "appName": "<app-name>",
  "destName": "in-cluster",
  "destNamespace": "<namespace>",
  "destServer": "https://kubernetes.default.svc",
  "labels": {},
  "project": "default",
  "userGivenName": "<app-name>"
}
```

## Step 6: Commit and push

Commit your changes and push to the repository. Argo CD automatically detects the new `config.json` and creates the Application.

## Example: Adding a simple application

For a complete example, see the existing jellyfin application at `kubernetes/cluster/active/apps/media/jellyfin/`.
