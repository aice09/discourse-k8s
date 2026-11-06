# Backup and restore

A production backup strategy must cover both the PostgreSQL database and user uploads.

The chart's `backup` values are an integration contract; do not enable a generic backup CronJob
until its command is configured for the exact image and backup destination. The sample scaffold
does not claim a completed Discourse-native backup implementation.

Recommended:
- For CloudNativePG: use its supported object-store backup and WAL archiving configuration.
- For standard PostgreSQL: use pgBackRest or WAL-G for base backups and WAL/PITR; alternatively
  use a tested logical dump for smaller deployments.
- For uploads: back up the CephFS volume or use S3 object storage with versioning/lifecycle rules.
- Store backups outside the Kubernetes cluster and test restores regularly.

Restore drill:
1. Provision isolated staging namespace and database.
2. Restore PostgreSQL to a compatible major version.
3. Restore uploads or reconnect the correct object bucket.
4. Deploy the exact matching Discourse image and plugins.
5. Validate login, topics, attachments, email and background jobs.
6. Record recovery time and data-loss window.
