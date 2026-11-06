# PHLOPENTECH Discourse on Kubernetes

A GitOps-oriented Kubernetes packaging project for Discourse, built around pinned upstream
Discourse sources and a custom Helm chart.

> **Status: implementation scaffold / staging validation required.** This repository provides
> the chart contract, Kubernetes resources, CI workflows, release metadata and operational
> runbooks. It is not a claim that every Discourse runtime process, migration, backup/restore
> and HA failover path has been validated against a production upstream image. Do not expose
> a deployment to the public internet until the image contract and restore procedure have
> passed staging tests.

## Architecture

- Discourse source: `discourse/discourse`
- Official Docker build definitions: `discourse/discourse_docker`
- Application image: GitHub Container Registry (GHCR)
- Helm chart: packaged and published as an OCI artifact in GHCR
- Artifact discovery: Artifact Hub indexes the OCI chart; it does not host the chart image
- GitOps: Argo CD
- Networking: generic Kubernetes Ingress or Gateway API HTTPRoute
- PostgreSQL providers: standard PostgreSQL StatefulSet (default), CloudNativePG, external
- Redis providers: standalone Redis StatefulSet (default), external
- Uploads: existing RWX PVC (recommended CephFS) or S3-compatible object storage

## Repository layout

```text
.
├── .github/workflows/          # image and chart CI/release
├── build/                      # pinned upstream build inputs and image contract
├── chart/discourse/            # Helm chart
├── deploy/                     # environment overlays and Argo CD Application
├── docs/                       # installation, upgrades, backup/restore
├── scripts/                    # validation and build helpers
└── artifacthub-repo.yml         # Artifact Hub repository metadata
```

## Quick start

1. Create a GitHub repository named `discourse-k8s` and push this source.
2. Configure GitHub Actions permissions: `contents: read`, `packages: write`.
3. Select an official Discourse tag/channel in the `Build and publish Discourse image` workflow (for example a version tag, `release`, `latest`, or `esr`). The workflow resolves it to an immutable commit SHA. Set repository variable `DISCOURSE_DOCKER_REF` to an immutable 40-character commit SHA. Complete `build/IMAGE_CONTRACT.md` before enabling image publication.
5. Run chart validation:
   ```bash
   helm lint chart/discourse
   helm template discourse chart/discourse -f deploy/production/values.yaml
   ```
6. Install required operators before selecting operator-backed modes:
   - CloudNativePG operator for `database.provider: cloudnative-pg`.
   - cert-manager if managing certificates through cert-manager.
   - Gateway API CRDs/controller if `networking.mode: gateway-api`.
7. Install the chart in staging first. Verify migrations, SMTP, uploads, background jobs,
   backup and restore before production.

## Install from GHCR OCI chart

After the first successful release:

```bash
helm registry login ghcr.io
helm install discourse oci://ghcr.io/OWNER/charts/discourse \
  --version 0.1.0 \
  --namespace discourse --create-namespace \
  -f deploy/production/values.yaml
```

Replace `OWNER` with the GitHub owner or organization.

## Image build caveat

The upstream `discourse_docker` project is a Docker/launcher-based distribution. Its multi-container
configuration is the reference for splitting data services from web processes. A Kubernetes
image must preserve Discourse's expected boot, process supervision, assets, plugins and migration
behavior. The image pipeline in this repository is deliberately gated; it must not be treated as
a verified production image builder until the maintainer has completed the tests in
`build/IMAGE_CONTRACT.md`. Do not substitute a generic Rails container or invent process commands.

## PostgreSQL modes

```yaml
database:
  provider: postgresql       # default | cloudnative-pg | external
```

- `postgresql`: chart-managed single-instance PostgreSQL StatefulSet. Not HA.
- `cloudnative-pg`: chart creates a CNPG Cluster custom resource; operator is installed separately.
- `external`: chart creates no database resources.

Redis is independently selected:

```yaml
redis:
  provider: standalone       # standalone | external
```

## Ingress and Gateway API

```yaml
networking:
  mode: ingress              # ingress | gateway-api | disabled
```

No ingress controller is hardcoded. The user supplies `ingressClassName` and annotations. Gateway API
requires Gateway API CRDs and a controller implementation.

## Security

- Never commit Secret values.
- Use SOPS + age, External Secrets Operator, or pre-created Kubernetes Secrets.
- Use immutable image tags/digests for production.
- Pin upstream source commits and plugin revisions.
- Keep database and Redis services internal.
- Enable TLS and test backup restoration.

## License

See `LICENSE`.
