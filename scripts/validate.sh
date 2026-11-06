#!/usr/bin/env bash
set -euo pipefail
helm lint chart/discourse
helm template discourse chart/discourse -f deploy/production/values.yaml >/tmp/discourse-rendered.yaml
echo "Helm validation passed."
