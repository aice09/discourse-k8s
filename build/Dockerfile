# Kubernetes image adapter for Discourse.
#
# Built from the official discourse/base image referenced by the pinned
# discourse_docker revision, with the Discourse source pinned to an exact commit.
# Assets are precompiled at build time against a throwaway PostgreSQL/Redis
# (see .github/workflows/build-image.yaml), mirroring the upstream bootstrap.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DISCOURSE_REF
ARG DISCOURSE_SHA
ARG DISCOURSE_DOCKER_REF
ARG BUILD_DB_HOST=127.0.0.1
ARG BUILD_DB_PORT=5432
ARG BUILD_DB_PASSWORD=ci-build-only
ARG BUILD_REDIS_HOST=127.0.0.1

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

WORKDIR /var/www/discourse

RUN test -n "${DISCOURSE_SHA}" && \
    sudo -H -E -u discourse bash -euc '\
      git fetch --tags --force origin "${DISCOURSE_SHA}" && \
      git -c advice.detachedHead=false checkout --force --detach "${DISCOURSE_SHA}" && \
      test "$(git rev-parse HEAD)" = "${DISCOURSE_SHA}" && \
      git config user.discourse-version "${DISCOURSE_REF}"'

RUN sudo -H -E -u discourse bash -euc '\
      bundle install --jobs "$(nproc --ignore=1)" --retry 3 && \
      bundle clean && \
      find vendor/bundle -name cache -not -path "*/gems/*" -type d -exec rm -rf {} + && \
      find vendor/bundle -name tmp -type d -exec rm -rf {} + && \
      CI=1 pnpm install --frozen-lockfile && pnpm prune'

# Needs a reachable database: build with `docker build --network host`.
RUN sudo -H -E -u discourse \
      DISCOURSE_HOSTNAME=build.invalid \
      DISCOURSE_DB_SOCKET= \
      DISCOURSE_DB_HOST="${BUILD_DB_HOST}" \
      DISCOURSE_DB_PORT="${BUILD_DB_PORT}" \
      DISCOURSE_DB_NAME=discourse \
      DISCOURSE_DB_USERNAME=discourse \
      DISCOURSE_DB_PASSWORD="${BUILD_DB_PASSWORD}" \
      DISCOURSE_REDIS_HOST="${BUILD_REDIS_HOST}" \
      bash -euc '\
        bundle exec rake db:migrate && \
        bundle exec rake assets:precompile:build && \
        SKIP_EMBER_CLI_COMPILE=1 bundle exec rake themes:update assets:precompile'

COPY docker-entrypoint.sh /usr/local/bin/discourse-entrypoint
RUN chmod 0755 /usr/local/bin/discourse-entrypoint

LABEL org.opencontainers.image.source="https://github.com/aice09/discourse-k8s" \
      org.opencontainers.image.description="Discourse for Kubernetes (web, sidekiq, migrate modes)" \
      io.discourse-k8s.discourse-ref="${DISCOURSE_REF}" \
      io.discourse-k8s.discourse-sha="${DISCOURSE_SHA}" \
      io.discourse-k8s.discourse-docker-ref="${DISCOURSE_DOCKER_REF}"

EXPOSE 3000
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/discourse-entrypoint"]
CMD ["web"]
