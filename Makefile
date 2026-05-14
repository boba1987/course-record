# Parent repo for course-record-backend + course-record-frontend (git submodules).
# Fresh clone: git clone --recurse-submodules <this-repo-url>
# Or after clone: make init

SUB_BACKEND  := course-record-backend
SUB_FRONTEND := course-record-frontend

.PHONY: help init dev backend frontend install-frontend

help:
	@echo "Targets:"
	@echo "  make init             git submodule update --init --recursive"
	@echo "  make dev              init, npm ci in frontend if needed, run backend + frontend (parallel)"
	@echo "  make backend          mvn spring-boot:run in $(SUB_BACKEND)"
	@echo "  make frontend         npm run dev in $(SUB_FRONTEND)"
	@echo "  make install-frontend npm ci in $(SUB_FRONTEND)"

init:
	git submodule update --init --recursive

install-frontend:
	cd $(SUB_FRONTEND) && npm ci

$(SUB_FRONTEND)/node_modules: $(SUB_FRONTEND)/package-lock.json
	cd $(SUB_FRONTEND) && npm ci

dev:
	$(MAKE) init
	test -f $(SUB_FRONTEND)/package-lock.json || (echo "error: $(SUB_FRONTEND) missing — run make init" >&2; exit 1)
	$(MAKE) $(SUB_FRONTEND)/node_modules
	$(MAKE) -j2 backend frontend

backend:
	cd $(SUB_BACKEND) && mvn spring-boot:run

frontend: $(SUB_FRONTEND)/node_modules
	cd $(SUB_FRONTEND) && npm run dev
