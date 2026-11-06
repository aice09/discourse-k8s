# Installation

## Prerequisites

- Kubernetes cluster and Helm 3.12+
- RWX uploads storage (CephFS recommended) or configured S3 upload backend
- Persistent RWO storage for PostgreSQL and Redis
- SMTP relay
- Kubernetes Secrets created before installation
- Ingress controller or Gateway API controller
- cert-manager if using the Certificate resource
- CloudNativePG operator only if selecting `database.provider: cloudnative-pg`

## Validate

```bash
helm lint chart/discourse
helm template discourse chart/discourse -f deploy/production/values.yaml
```

## Install

```bash
kubectl create namespace discourse
kubectl apply -f /path/to/managed-secrets.yaml
helm upgrade --install discourse chart/discourse \
  -n discourse -f deploy/production/values.yaml
```

## PostgreSQL provider selection

- `postgresql`: chart-managed single-instance StatefulSet.
- `cloudnative-pg`: requires CNPG operator and creates a Cluster custom resource.
- `external`: requires a reachable endpoint and pre-created Secret.

Do not switch providers in-place without a database migration and verified backup.

## Gateway API

Set `networking.mode: gateway-api` and configure `networking.gateway.parentRefs`.
The cluster must have the Gateway API `HTTPRoute` CRD and a compatible controller.
