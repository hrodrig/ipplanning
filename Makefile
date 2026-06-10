# ipplanning — tests, security, Docker (aligned with gghstats workflow patterns)

VERSION_RAW ?= $(shell v=$$(cat VERSION 2>/dev/null | tr -d '\n\r'); [ -n "$$v" ] && echo "$$v" || echo "0.0.0")
VERSION     := $(patsubst v%,%,$(VERSION_RAW))
TAG         := v$(VERSION)
COMMIT      := $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
BUILDDATE   := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
IMAGE       ?= ghcr.io/hrodrig/ipplanning
GRYPE_FAIL_ON ?= high
DOCKER_PLATFORM ?=
STRICT_RELEASE ?= 0
# Ephemeral MySQL for `make test` when IPPLANNING_DB_HOST is unset. Maps host port :3306; stop any local MySQL first.
MYSQL_TEST_CONTAINER ?= ipplanning-mysql-test
MYSQL_TEST_PORT ?= 3306

.DEFAULT_GOAL := help

.PHONY: help test test-prep test-run test-mysql-down cover lint security brakeman bundle-audit grype docker-build docker-build-amd64 docker-run docker-scan docker-push release-check compose-up compose-down tools

help:
	@echo "ipplanning — Rails IPAM"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Quality:"
	@echo "  test              MySQL for test (Docker :$(MYSQL_TEST_PORT) unless IPPLANNING_DB_HOST is set), db:prepare, bin/rails test"
	@echo "  test-prep         Only start/wait for test MySQL and write .make-mysql-test.env"
	@echo "  test-run          db:prepare + tests (expects make test-prep first)"
	@echo "  test-mysql-down   Stop Docker test MySQL and remove .make-mysql-test.env"
	@echo "  cover             Same prep as test, then run tests (coverage stub if COVERAGE set)"
	@echo "  lint              Brakeman + bundler-audit (static checks; no RuboCop yet)"
	@echo "  brakeman          Brakeman security scan"
	@echo "  bundle-audit      bundler-audit (gem CVEs)"
	@echo "  grype             Grype scan of project directory"
	@echo "  security          brakeman, bundle-audit, grype"
	@echo "  release-check     Semver VERSION, test, lint, security (+ docker-scan if STRICT_RELEASE=1)"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build      Build $(IMAGE):$(VERSION) (optional: DOCKER_PLATFORM=linux/amd64)"
	@echo "  docker-build-amd64  Same, forced linux/amd64"
	@echo "  docker-run        Run built image on PORT=3000 (expects external MySQL via env)"
	@echo "  docker-scan       Build and Grype-scan the image"
	@echo "  docker-push       Push $(IMAGE):$(VERSION) (requires: docker login ghcr.io)"
	@echo "  compose-up        docker compose up -d --build (db + web)"
	@echo "  compose-down      docker compose down"
	@echo ""
	@echo "Tooling:"
	@echo "  tools             bundle install (after Gemfile changes)"
	@echo ""
	@echo "Current version: $(VERSION) (tag: $(TAG))  image: $(IMAGE)"
	@echo "Test DB: set IPPLANNING_DB_HOST (and optional IPPLANNING_DB_PORT) to use your MySQL; otherwise Docker maps host port $(MYSQL_TEST_PORT)."

test-prep:
	@set -e; \
	rm -f .make-mysql-test.env; \
	if [ -n "$$IPPLANNING_DB_HOST" ]; then \
	  H="$$IPPLANNING_DB_HOST"; P="$${IPPLANNING_DB_PORT:-3306}"; \
	  echo "Using MySQL at $$H:$$P (IPPLANNING_DB_HOST is set)."; \
	  ok=0; \
	  for i in $$(seq 1 60); do \
	    if ruby -rsocket -e "TCPSocket.new(ARGV[0], ARGV[1].to_i).close" "$$H" "$$P" 2>/dev/null; then ok=1; break; fi; \
	    sleep 1; \
	  done; \
	  if [ "$$ok" != 1 ]; then echo "Timeout: could not open TCP $$H:$$P"; exit 1; fi; \
	  echo "export IPPLANNING_DB_HOST=$$H" > .make-mysql-test.env; \
	  echo "export IPPLANNING_DB_PORT=$$P" >> .make-mysql-test.env; \
	else \
	  command -v docker >/dev/null 2>&1 || { echo "Docker is required for make test unless IPPLANNING_DB_HOST is set."; exit 1; }; \
	  docker rm -f $(MYSQL_TEST_CONTAINER) 2>/dev/null || true; \
	  docker run -d --name $(MYSQL_TEST_CONTAINER) \
	    -e MYSQL_ROOT_PASSWORD=root \
	    -e MYSQL_DATABASE=ipplanning_test \
	    -e MYSQL_USER=user \
	    -e MYSQL_PASSWORD=password \
	    -p $(MYSQL_TEST_PORT):3306 \
	    mysql:8.0; \
	  ok=0; \
	  for i in $$(seq 1 90); do \
	    if docker exec $(MYSQL_TEST_CONTAINER) mysqladmin ping -h 127.0.0.1 -uroot -proot --silent 2>/dev/null; then ok=1; break; fi; \
	    sleep 1; \
	  done; \
	  if [ "$$ok" != 1 ]; then echo "Timeout waiting for Docker MySQL ($(MYSQL_TEST_CONTAINER))."; docker logs $(MYSQL_TEST_CONTAINER) 2>&1 | tail -30; exit 1; fi; \
	  echo "Started Docker MySQL ($(MYSQL_TEST_CONTAINER) on 127.0.0.1:$(MYSQL_TEST_PORT))."; \
	  echo "export IPPLANNING_DB_HOST=127.0.0.1" > .make-mysql-test.env; \
	  echo "export IPPLANNING_DB_PORT=$(MYSQL_TEST_PORT)" >> .make-mysql-test.env; \
	fi

test-run:
	@set -e; \
	test -f .make-mysql-test.env || { echo "Missing .make-mysql-test.env — run make test-prep first."; exit 1; }; \
	. ./.make-mysql-test.env; \
	export RAILS_ENV=test; \
	bin/rails db:prepare; \
	bin/rails test

test: test-prep test-run

test-mysql-down:
	-docker rm -f $(MYSQL_TEST_CONTAINER) 2>/dev/null
	-rm -f .make-mysql-test.env

# Lightweight coverage without adding SimpleCov: use Ruby's coverage if desired later.
cover: test-prep
	@set -e; \
	. ./.make-mysql-test.env; \
	export RAILS_ENV=test; \
	bin/rails db:prepare; \
	COVERAGE=1 bin/rails test 2>/dev/null || bin/rails test

brakeman:
	bundle exec brakeman --no-pager --quiet

bundle-audit:
	bundle exec bundle-audit check --update

lint: brakeman bundle-audit

grype:
	@if command -v grype >/dev/null 2>&1; then \
		grype dir:. --exclude './tmp/**' --exclude './log/**' --exclude './coverage/**' ; \
	else \
		echo "grype not found locally, using container image..."; \
		docker run --rm --pull=always -v "$(PWD):/workspace" anchore/grype:latest \
			dir:/workspace --exclude './tmp/**' --exclude './log/**' --exclude './coverage/**' ; \
	fi

security: brakeman bundle-audit grype

docker-build:
	@set -e; \
	opts=""; \
	if [ -n "$(strip $(DOCKER_PLATFORM))" ]; then opts="--platform $(DOCKER_PLATFORM)"; fi; \
	DOCKER_BUILDKIT=1 docker build $$opts \
		--build-arg VERSION=$(VERSION) --build-arg GIT_SHA=$(COMMIT) --build-arg BUILDDATE=$(BUILDDATE) \
		-t $(IMAGE):$(VERSION) -t ipplanning:$(VERSION) .

docker-build-amd64:
	$(MAKE) docker-build DOCKER_PLATFORM=linux/amd64

docker-scan: docker-build
	@if command -v grype >/dev/null 2>&1; then \
		grype $(IMAGE):$(VERSION) --fail-on $(GRYPE_FAIL_ON) ; \
	else \
		docker run --rm --pull=always -v /var/run/docker.sock:/var/run/docker.sock anchore/grype:latest \
			$(IMAGE):$(VERSION) --fail-on $(GRYPE_FAIL_ON) ; \
	fi

docker-run:
	@test -n "$$SECRET_KEY_BASE" || { echo "Set SECRET_KEY_BASE for production mode."; exit 1; }
	docker run --rm -e RAILS_FORCE_SSL=false -e SECRET_KEY_BASE -e IPPLANNING_DATABASE_HOST -e IPPLANNING_DATABASE_USER -e IPPLANNING_DATABASE_PASSWORD -p 3000:3000 $(IMAGE):$(VERSION)

docker-push:
	docker push $(IMAGE):$(VERSION)

compose-up:
	docker compose up -d --build

compose-down:
	docker compose down

tools:
	bundle install

release-check:
	@test -f VERSION || (echo "VERSION file is required"; exit 1)
	@echo "Release version: $(VERSION) (tag: $(TAG))"
	@echo "$(VERSION)" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$$' || (echo "VERSION must be semantic (e.g. 0.9.0)"; exit 1)
	@$(MAKE) test
	@$(MAKE) lint
	@$(MAKE) grype
	@if [ "$(STRICT_RELEASE)" = "1" ]; then \
		echo "STRICT_RELEASE=1 -> running docker-scan"; \
		$(MAKE) docker-scan; \
	else \
		echo "STRICT_RELEASE=0 -> skipping docker-scan (set STRICT_RELEASE=1 to include)"; \
	fi
	@echo "All release checks passed."
