# Parent repo: submodules + Docker (MySQL + Spring Boot) + Next.js on the host.
# Fresh clone: git clone --recurse-submodules <this-repo-url>
# Or: make init

SUB_BACKEND  := course-record-backend
SUB_FRONTEND := course-record-frontend
COMPOSE      := docker compose
# Public OpenAPI JSON (no auth); used to detect when the app is accepting HTTP.
BACKEND_READY_URL ?= http://127.0.0.1:8080/course-record/v3/api-docs

.PHONY: help init dev dev-local docker-up docker-down wait-backend \
	backend frontend install-frontend

help:
	@echo "Targets:"
	@echo "  make init              git submodule update --init --recursive"
	@echo "  make dev               Docker MySQL + backend, wait for API, then Next.js (foreground)"
	@echo "                         Ctrl+C stops Next.js only; run: make docker-down"
	@echo "  make dev-local         Local mvn + Next.js in parallel (needs local MySQL + config)"
	@echo "  make docker-up         docker compose up -d --build"
	@echo "  make docker-down       docker compose down"
	@echo "  make wait-backend      HTTP wait until $(BACKEND_READY_URL) responds"
	@echo "  make backend           mvn spring-boot:run in $(SUB_BACKEND)"
	@echo "  make frontend          npm run dev in $(SUB_FRONTEND)"
	@echo "  make install-frontend  npm ci in $(SUB_FRONTEND)"

init:
	git submodule update --init --recursive

install-frontend:
	cd $(SUB_FRONTEND) && npm ci

$(SUB_FRONTEND)/node_modules: $(SUB_FRONTEND)/package-lock.json
	cd $(SUB_FRONTEND) && npm ci

docker-up:
	$(COMPOSE) up -d --build

docker-down:
	$(COMPOSE) down

wait-backend:
	@echo "Waiting for backend at $(BACKEND_READY_URL) ..."
	@i=0; \
	while [ $$i -lt 90 ]; do \
	  if curl -sf "$(BACKEND_READY_URL)" >/dev/null; then \
	    echo "Backend is ready."; \
	    exit 0; \
	  fi; \
	  i=$$((i+1)); \
	  printf "  attempt %s/90 (sleep 2s)\n" "$$i"; \
	  sleep 2; \
	done; \
	echo "Backend did not become ready in time." >&2; \
	exit 1

dev: init $(SUB_FRONTEND)/node_modules
	test -f $(SUB_FRONTEND)/package-lock.json || (echo "error: $(SUB_FRONTEND) missing — run make init" >&2; exit 1)
	$(MAKE) docker-up
	$(MAKE) wait-backend
	@echo "Next.js starting. Containers keep running after Ctrl+C — use: make docker-down"
	cd $(SUB_FRONTEND) && npm run dev

dev-local:
	$(MAKE) init
	test -f $(SUB_FRONTEND)/package-lock.json || (echo "error: $(SUB_FRONTEND) missing — run make init" >&2; exit 1)
	$(MAKE) $(SUB_FRONTEND)/node_modules
	$(MAKE) -j2 backend frontend

backend:
	cd $(SUB_BACKEND) && mvn spring-boot:run

frontend: $(SUB_FRONTEND)/node_modules
	cd $(SUB_FRONTEND) && npm run dev
