---
sidebar_position: 2
title: ApplicationSet Config Format
---

# ApplicationSet Config Format

Each application or addon overlay includes a `config.json` file used by Argo CD ApplicationSets.

## Required fields

| Field | Description |
| --- | --- |
| `appName` | Application name shown in Argo CD |
| `userGivenName` | Human-friendly name (usually same as `appName`) |
| `destName` | Destination cluster name (typically `in-cluster`) |
| `destServer` | Kubernetes API server URL |
| `destNamespace` | Target namespace for the application |
| `project` | Argo CD project name |
| `labels` | Custom labels map |
| `annotations` | Custom annotations map |

## Example

```json
{
  "annotations": {},
  "appName": "example-app",
  "destName": "in-cluster",
  "destNamespace": "example",
  "destServer": "https://kubernetes.default.svc",
  "labels": {},
  "project": "default",
  "userGivenName": "example-app"
}
```

## Related guides

- [Add a New Application](../how-to-guides/add-application)
- [GitOps Workflow](../explanation/gitops-workflow)
