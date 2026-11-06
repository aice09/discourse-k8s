#!/usr/bin/env bash
set -euo pipefail
VERSION="${1:?Usage: package-chart.sh VERSION}"
helm lint chart/discourse
helm package chart/discourse --version "$VERSION" --app-version "$VERSION" --destination dist
