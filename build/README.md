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

## Image adapter (`Dockerfile`, `docker-entrypoint.sh`)

`Dockerfile` starts from the `discourse/base` image named in
`samples/web_only.yml` at the pinned `DISCOURSE_DOCKER_REF` (resolved to a digest by the
workflow), checks out the exact resolved Discourse commit, installs dependencies and
precompiles assets against a throwaway PostgreSQL/Redis (`docker build --network host`).

`/usr/local/bin/discourse-entrypoint` provides the runtime modes:

| Mode | Command run (as `discourse:www-data`) |
|------|---------------------------------------|
| `web` | `pitchfork -E production -c config/pitchfork.conf.rb` on port 3000, no embedded Sidekiq, no nginx |
| `sidekiq` | `sidekiq -e production` with the standard Discourse queue weights |
| `migrate` | `rake db:migrate` |
| `exec <cmd>` | arbitrary command with the same environment |

Configuration comes from `DISCOURSE_*` environment variables (Discourse's env provider).
The Secret named by `discourse.existingSecret` must provide at least `DISCOURSE_DB_PASSWORD`,
`DISCOURSE_REDIS_PASSWORD`, `DISCOURSE_SECRET_KEY_BASE`, and the `DISCOURSE_SMTP_*` settings.

Run the workflow with `build_image: true` to build and smoke test; add `publish_image: true`
to push to GHCR. Set repository variable `DISCOURSE_DOCKER_REF` first.

## Mandatory Kubernetes image adapter validation

The official Discourse Docker image setup includes process supervision and a launcher-driven
configuration. This repository's split web/Sidekiq Kubernetes chart needs a validated image
adapter that preserves upstream boot, migration, assets, plugins, signals and health behavior.
Complete `IMAGE_CONTRACT.md` before turning on the image publication workflow.
