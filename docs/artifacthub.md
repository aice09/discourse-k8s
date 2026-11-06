# Publish to Artifact Hub

Artifact Hub indexes the OCI Helm chart; GHCR remains the artifact registry.

1. Publish a versioned chart to `oci://ghcr.io/OWNER/charts/discourse`.
2. Sign in to Artifact Hub and add a Helm OCI repository:
   `oci://ghcr.io/OWNER/charts/discourse`
3. For OCI repositories, publish `artifacthub-repo.yml` as the special `artifacthub.io` tag
   using ORAS. The release workflow includes this metadata push.
4. Add the Artifact Hub repository ID to `artifacthub-repo.yml` after registration if you want
   to claim ownership / pursue publisher verification.
5. Confirm the package appears and its install instructions point to GHCR.

Example install:

```bash
helm install discourse oci://ghcr.io/OWNER/charts/discourse --version 0.1.0
```

Artifact Hub does not store the chart package; it indexes metadata from the OCI registry.
