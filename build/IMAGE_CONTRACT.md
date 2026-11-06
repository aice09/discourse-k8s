# Discourse image contract — mandatory validation

A selected official Discourse tag is the source input. The build pipeline resolves it to a commit
SHA, then builds the image using pinned `discourse_docker` definitions.

The Kubernetes image adapter must provide validated runtime modes:
- web: start the supported Discourse web application process and required process supervision.
- sidekiq: start Sidekiq using the same source, assets, dependencies and plugins.
- migrate: execute the supported migration procedure exactly once.
- all modes: use runtime-provided secrets, shared uploads, graceful SIGTERM and health checks.

Do not assume arbitrary `bundle exec` commands are a supported substitute for the upstream
launcher/templates. The official image/build project uses Buildx Bake and multiple image targets.
Inspect the pinned revision and verify its declared Bake targets.

Required staging tests:
1. Build exact selected Discourse tag + pinned Docker build definitions.
2. Record source tag, source commit, Docker definitions commit, base image digest and image digest.
3. Verify web startup and readiness; Sidekiq starts and drains queues.
4. Verify migration on an isolated copy of the target database.
5. Verify web and Sidekiq can read/write the same uploads when scheduled on different nodes.
6. Verify SMTP, registration, password resets, uploads, plugins and scheduled jobs.
7. Verify SIGTERM and rolling replacement behavior.
8. Create and restore a full database + uploads backup.
9. Test version upgrade and rollback/restore in staging.

CI image publication remains gated until these checks are implemented and passed.
