# Architecture

```text
Internet
  |
Ingress Controller OR Gateway API Controller
  |
Discourse Web Service
  |
  +-- Web replicas (Rails)
  +-- Sidekiq workers
  |
  +-- PostgreSQL provider
  |     +-- standard StatefulSet (default)
  |     +-- CloudNativePG Cluster
  |     +-- external endpoint
  |
  +-- Redis provider
  |     +-- standalone StatefulSet (default)
  |     +-- external endpoint
  |
  +-- shared uploads (CephFS RWX or S3)
  +-- SMTP relay
  +-- backup destination
```

PostgreSQL standard mode is single-instance and is not HA. CloudNativePG provides HA only
when its operator, storage, anti-affinity and backup configuration are correctly installed.
