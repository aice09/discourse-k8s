# Upgrade procedure

1. Review Discourse release notes and upstream Docker template changes.
2. Pin a new Discourse commit, discourse_docker commit, base image digest and plugin revisions.
3. Build and test the candidate image in staging.
4. Take and verify a complete database + uploads backup.
5. Run the supported migration procedure exactly once.
6. Deploy web and Sidekiq using the same image digest.
7. Validate startup, queues, SMTP, uploads, plugins and metrics.
8. Promote the tested image and chart version through Argo CD.

Do not assume a database migration is reversible. Rollback may require restoring the database
and uploads together.
