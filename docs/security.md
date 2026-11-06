# Security

- Use SOPS + age or External Secrets Operator.
- Never store credentials in values files or Git.
- Restrict database and Redis services to application namespaces.
- Configure NetworkPolicies according to the selected CNI and ingress implementation.
- Use TLS and validate trusted proxy headers.
- Pin image tags and digests; scan and sign release images.
- Do not run the application as root unless the validated upstream image requires it.
- Review plugin source and pin immutable revisions.
