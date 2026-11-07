#!/bin/bash
# Entrypoint for the Kubernetes Discourse image: web | sidekiq | migrate | exec <cmd...>
set -euo pipefail

home=/var/www/discourse
cd "$home"

prepare_shared() {
  mkdir -p /shared/uploads /shared/backups /shared/tmp/backups /shared/tmp/restores
  find /shared/uploads /shared/backups /shared/tmp ! \( -user discourse -group www-data \) \
    -exec chown discourse:www-data {} +
  ln -sfn /shared/uploads "$home/public/uploads"
  ln -sfn /shared/backups "$home/public/backups"
  ln -sfn /shared/tmp/backups "$home/tmp/backups"
  ln -sfn /shared/tmp/restores "$home/tmp/restores"
}

as_discourse() {
  export HOME=/home/discourse USER=discourse
  exec chpst -u discourse:www-data -U discourse:www-data "$@"
}

mode="${1:-web}"
shift || true

case "$mode" in
  web)
    prepare_shared
    # No nginx in this image: Rails serves static assets, TLS is terminated by the ingress.
    export UNICORN_SIDEKIQS=0 UNICORN_BIND_ALL=1
    export DISCOURSE_SERVE_STATIC_ASSETS="${DISCOURSE_SERVE_STATIC_ASSETS:-true}"
    as_discourse bundle exec pitchfork -E production -c config/pitchfork.conf.rb "$@"
    ;;
  sidekiq)
    prepare_shared
    as_discourse bundle exec sidekiq -e production \
      -c "${DISCOURSE_SIDEKIQ_WORKERS:-5}" -t 25 \
      -q critical,8 -q default,4 -q low,2 -q ultra_low,1 "$@"
    ;;
  migrate)
    prepare_shared
    as_discourse bundle exec rake db:migrate "$@"
    ;;
  exec)
    as_discourse "$@"
    ;;
  *)
    echo "usage: discourse-entrypoint {web|sidekiq|migrate|exec <cmd...>}" >&2
    exit 64
    ;;
esac
