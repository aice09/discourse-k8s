# Upstream build inputs

## Discourse source selector

The build pipeline accepts `DISCOURSE_REF` as:
- An official Discourse Git tag from https://github.com/discourse/discourse/tags
- A supported release channel such as `latest`, `release`, or `esr`
- For development/testing only, a branch or commit SHA

For production releases, use an immutable version tag where possible. The workflow resolves
the selected ref to a commit SHA and records both the tag/ref and SHA as OCI labels and build
metadata. This makes the exact source revision auditable even if a moving channel later advances.

Discourse release channel guidance:
- `main`: development; not recommended for production.
- `latest`: actively updated tested channel.
- `release`: latest monthly release line.
- `esr`: extended-support release line.

## Docker build definitions

The companion build repository is `https://github.com/discourse/discourse_docker`.
Pin `DISCOURSE_DOCKER_REF` to an immutable commit SHA. Do not automatically use its `main`
branch for production builds.

The official build documentation uses Docker Buildx Bake. Inspect `docker-bake.hcl` and the
Dockerfiles at the selected pinned revision and use a target that is actually declared there.
Do not assume a target name or image build command based on an old pipeline.

## Mandatory Kubernetes image adapter validation

The official Discourse Docker image setup includes process supervision and a launcher-driven
configuration. This repository's split web/Sidekiq Kubernetes chart needs a validated image
adapter that preserves upstream boot, migration, assets, plugins, signals and health behavior.
Complete `IMAGE_CONTRACT.md` before turning on the image publication workflow.
