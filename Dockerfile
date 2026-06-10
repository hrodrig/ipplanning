# Multi-stage production image (see Makefile: docker-build, docker-scan).
# Runtime expects MySQL and env: SECRET_KEY_BASE, IPPLANNING_DATABASE_* (see config/database.yml).
ARG RUBY_VERSION=3.3.0

FROM ruby:${RUBY_VERSION}-slim-bookworm AS builder

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    git \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment "true" \
  && bundle config set --local without "development:test" \
  && bundle install -j4 --retry 3

COPY . .

ARG VERSION=dev
ARG GIT_SHA=unknown
ARG BUILDDATE=unknown

ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy_secret_for_asset_precompile_replace_at_runtime

RUN bundle exec rails assets:precompile \
  && rm -rf tmp/cache

FROM ruby:${RUBY_VERSION}-slim-bookworm AS runtime

LABEL org.opencontainers.image.title="ipplanning"
LABEL org.opencontainers.image.description="IP Address Management (IPAM) on Rails"
LABEL org.opencontainers.image.source="https://github.com/hrodrig/ipplanning"

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    default-mysql-client \
    libmariadb3 \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd --system --gid 1000 rails \
  && useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

WORKDIR /app

ARG VERSION=dev
ARG GIT_SHA=unknown
ARG BUILDDATE=unknown

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails /app /app

ENV IPPLANNING_IMAGE_VERSION=${VERSION} \
    IPPLANNING_IMAGE_GIT_SHA=${GIT_SHA} \
    IPPLANNING_IMAGE_BUILD_DATE=${BUILDDATE}

USER rails:rails

ENTRYPOINT ["/app/bin/docker-entrypoint"]
EXPOSE 3000

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
